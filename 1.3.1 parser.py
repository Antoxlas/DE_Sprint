# 1. Парсинг hh.ru
import json
import requests as req
import time
from bs4 import BeautifulSoup
from fake_useragent import UserAgent
from tqdm import tqdm

data = {
    "data": []
}

counter = 0  # Счетчик обработанных вакансий
xp = ["noExperience", "between1And3", "between3And6", "moreThan6"]
for p in xp:
    page = 0  # На hh отсчет идёт с 0
    while True:
        url = f"https://hh.ru/search/vacancy?&text=python+%D1%80%D0%B0%D0%B7%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%87%D0%B8%D0%BA&experience={p}&order_by=relevance&items_on_page=20&page={page}"
        resp = req.get(url, headers={"User-Agent": UserAgent().firefox})
        soup = BeautifulSoup(resp.text, "lxml")

        tags = soup.find_all(attrs={"data-qa": "serp-item__title"})
        blocks = soup.find_all(attrs={"class": "vacancy-serp-item__layout"}) # Блоки вакансий в выдаче на одной страницы, нужны для парсинга региона
        for vacancy, block in tqdm(zip(tags, blocks), total=len(blocks)):
            # print(vacancy.text, vacancy.attrs["href"])
            # time.sleep(2)
            url_object = vacancy.attrs["href"]
            resp_object = req.get(url_object, headers={"User-Agent": UserAgent().firefox})
            soup_object = BeautifulSoup(resp_object.text, "lxml")
            tag_title = vacancy.text

            tag_salary = soup_object.find("div", {"class":"wrapper-flat--H4DVL_qLjKLCo1sytcNI"})
            if tag_salary is not None:  # Тег может отсутствовать
                tag_salary = soup_object.find("div", {"class": "wrapper-flat--H4DVL_qLjKLCo1sytcNI"}).find(
                    attrs={"data-qa": "vacancy-salary"}).text
            else:
                tag_salary = None

            tag_work_experience = soup_object.find(attrs={"class": "wrapper-flat--H4DVL_qLjKLCo1sytcNI"})
            if tag_work_experience is not None:
                tag_work_experience = soup_object.find(
                    attrs={"class": "wrapper-flat--H4DVL_qLjKLCo1sytcNI"}).find("span", attrs={"data-qa": "vacancy-experience"}).text
            else:
                tag_work_experience = None

            tag_region = block.find("div", {"data-qa": "vacancy-serp__vacancy-address"})
            if tag_region is not None:
                tag_region = block.find("div", {"data-qa": "vacancy-serp__vacancy-address"}).text.split(",", 1)[0]
            else:
                tag_region = None

            data["data"].append({"title": tag_title, "work experience": tag_work_experience, "salary": tag_salary, "region": tag_region})
            with open("data.json", "w+") as file:
                json.dump(data, file, ensure_ascii=False, indent='\t')
            counter += 1

        is_end = soup.find("a", {"data-qa": "pager-next"})
        if is_end is None:  # Если кнопка "Далее" отсутствует, значит, это была последняя страница
            break
        page += 1
print(f"Vacancies parsed: {counter}")


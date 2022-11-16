# Функция, которая возвращает значение множителя
# для заданного разряда в заданном числе
def digits(number, n):
    """
    number - заданное число
    n - номер разряда, начиная с нулевого
    """
    return int((number % 10**(n + 1) - number % 10**n) / 10**n)
# Словарь, который содержит римские обозначения для 
# значений 1 и 5 соответствующих номеров разряда
dic = {
    0: {'1': 'I', '5': 'V'},
    1: {'1': 'X', '5': 'L'},
    2: {'1': 'C', '5': 'D'},
    3: {'1': 'M'}
}
# Функция, которая подставляет римское обозначение из словаря
# для заданного номера разряда и значения множителя
def mapping(dic, digit, value):
    if value >= 1 and value <= 3:
        return value * dic[digit]['1']
    elif value == 4:
        return dic[digit]['1'] + dic[digit]['5']
    elif value >= 5 and value <= 8:
        return dic[digit]['5'] + (value - 5) * dic[digit]['1']
    elif value == 9:
        return dic[digit]['1'] + dic[digit + 1]['1']
    elif value == 0:
        return ''
# Функция, которая делает преобразование из арабской записи в римскую
def roman(arabic_number):
    roman_number = ''
    for i in [3, 2, 1, 0]:
        value = digits(arabic_number, i)
        roman_number += mapping(dic, i, value)
    return roman_number
examples = [3, 9, 1945, 40, 90, 6, 7, 400, 2000]
for example in examples:
    print(example, '"' + roman(example) + '"')

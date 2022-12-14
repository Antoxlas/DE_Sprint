create view salary_coef as
    select emp.id, emp.salary, emp.department_id,
       1 -
    (case when q1 = 'A' then -0.2 when q1 = 'B' then -0.1 when q1 = 'C' then 0 when q1 = 'D' then 0.1 when q1 = 'E' then 0.2 end) -
    (case when q2 = 'A' then -0.2 when q2 = 'B' then -0.1 when q2 = 'C' then 0 when q2 = 'D' then 0.1 when q2 = 'E' then 0.2 end) -
    (case when q3 = 'A' then -0.2 when q3 = 'B' then -0.1 when q3 = 'C' then 0 when q3 = 'D' then 0.1 when q3 = 'E' then 0.2 end) -
    (case when q4 = 'A' then -0.2 when q4 = 'B' then -0.1 when q4 = 'C' then 0 when q4 = 'D' then 0.1 when q4 = 'E' then 0.2 end)
    as coef,
    emp.salary * (1 -
    (case when q1 = 'A' then -0.2 when q1 = 'B' then -0.1 when q1 = 'C' then 0 when q1 = 'D' then 0.1 when q1 = 'E' then 0.2 end) -
    (case when q2 = 'A' then -0.2 when q2 = 'B' then -0.1 when q2 = 'C' then 0 when q2 = 'D' then 0.1 when q2 = 'E' then 0.2 end) -
    (case when q3 = 'A' then -0.2 when q3 = 'B' then -0.1 when q3 = 'C' then 0 when q3 = 'D' then 0.1 when q3 = 'E' then 0.2 end) -
    (case when q4 = 'A' then -0.2 when q4 = 'B' then -0.1 when q4 = 'C' then 0 when q4 = 'D' then 0.1 when q4 = 'E' then 0.2 end))
    as prize
    from evaluations ev
left join employees emp on ev.emp_id = emp.id;
create  view indexation as
select id, salary, department_id, coef, salary + (salary *
       case when coef > 1.2 then 0.2
        when coef <= 1.2 and coef > 1 then 0.1
        else 0 end) as new_salary
from salary_coef;
--задание 2 a
select fio, max(salary) max_salary
from employees
group by fio
order by max_salary desc
limit 1;

--Задание 2 b
select distinct split_part(fio, ' ', 2) last_name
from employees
order by last_name;

--задание 2 c
select levels, avg(age(now(), startdate)) as experience
from employees
group by levels;

--задание 2 d
select fio, names
from employees emp
left join department dp on emp.department_id = dp.dp_id;

--задание 2 e
with dep_max_sal as (
    select department_id, max(salary) as max_salary
    from employees
    group by department_id
)
select names, fio, max_salary
from dep_max_sal dms
left join employees emp on dms.department_id = emp.department_id and dms.max_salary = emp.salary
left join department dp on dms.department_id = dp.dp_id;

--задание 2 f
with max_prize as (
    select department_id, sum(prize) total_prize
    from salary_coef
    group by department_id
) select names, total_prize
from max_prize mp
left join department dp on mp.department_id = dp.dp_id
order by total_prize desc
limit 1;

--заданеи 2 g
select * from indexation;

--задание 2 h
with avg_salary_exp as (
    select department_id, avg(age(now(), startdate)) avg_exp, round(avg(salary)) avg_salary
    from employees emp
    group by department_id
), counts as (
    select department_id,
           count(case when levels = 'jun' then id end) as jun_count,
           count(case when levels = 'middle' then id end) as middle_count,
           count(case when levels = 'senior' then id end) as senior_count,
           count(case when levels = 'lead' then id end) as lead_count
    from employees emp
    group by department_id
), sum_salary_before as (
    select department_id, sum(salary) as before_salary
    from employees emp
    group by department_id
),sum_salary_after as (
    select department_id, sum(new_salary) as after_salary
    from indexation
    group by department_id
    union all
    select department_id, sum(salary) as after_salary
    from employees
    where department_id = 6
    group by department_id

), count_eval as (
    select department_id,
    count(case when q1 = 'A' then 1 end) + count(case when q2 = 'A' then 1 end) +
    count(case when q3 = 'A' then 1 end) + count(case when q4 = 'A' then 1 end) as count_A,

    count(case when q1 = 'B' then 1 end) + count(case when q2 = 'B' then 1 end) +
    count(case when q3 = 'B' then 1 end) + count(case when q4 = 'B' then 1 end) as count_B,

    count(case when q1 = 'C' then 1 end) + count(case when q2 = 'C' then 1 end) +
    count(case when q3 = 'C' then 1 end) + count(case when q4 = 'C' then 1 end) as count_C,

    count(case when q1 = 'D' then 1 end) + count(case when q2 = 'D' then 1 end) +
    count(case when q3 = 'D' then 1 end) + count(case when q4 = 'D' then 1 end) as count_D,

    count(case when q1 = 'E' then 1 end) + count(case when q2 = 'E' then 1 end) +
    count(case when q3 = 'E' then 1 end) + count(case when q4 = 'E' then 1 end) as count_E
    from evaluations ev
    left join employees emp on ev.emp_id = emp.id
    group by department_id
), prize as (
    select department_id, round(avg(coef), 1) as avg_coef, sum(prize) as sum_prize
    from salary_coef
    group by department_id
)
select
       dp.names department, fio full_name_manager, emp_count,
       avg_exp avg_expirience, avg_salary, jun_count, middle_count, senior_count, lead_count,
       before_salary before_index_salary, after_salary after_index_salary,
       coalesce(count_A, 0) counts_A, coalesce(count_B, 0) counts_B,
       coalesce(count_C, 0) counts_C, coalesce(count_D, 0) counts_D,
       coalesce(count_E, 0) counts_E, coalesce(avg_coef, 0) avg_coef_prize,
       coalesce(sum_prize, 0) sum_prize,
       before_salary + coalesce(sum_prize, 0) before_index_sum_salary_and_prize,
       after_salary + coalesce(sum_prize, 0) after_index_sum_salary_and_prize,
       1 - round((before_salary + coalesce(sum_prize, 0))/(after_salary + coalesce(sum_prize, 0)), 2) as percent

from departments dmp
left join department dp on dmp.names = dp.names
left join avg_salary_exp ase on ase.department_id = dp.dp_id
left join counts cnt on cnt.department_id = dp.dp_id
left join sum_salary_before ssb on ssb.department_id = dp.dp_id
left join sum_salary_after ssa on ssa.department_id = dp.dp_id
left join count_eval ca on ca.department_id = dp.dp_id
left join prize on prize.department_id = dp.dp_id;

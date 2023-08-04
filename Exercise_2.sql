CREATE OR REPLACE PACKAGE high_salary IS

    TYPE all_needed_information IS RECORD ( employee_id employees.employee_id%TYPE,
                                            first_name employees.first_name%TYPE,
                                            last_name employees.last_name%TYPE,
                                            salary employees.salary%TYPE,
                                            department_id employees.department_id%TYPE,
                                            department_name departments.department_name%TYPE,
                                            job_id employees.job_id%TYPE,
                                            job_title jobs.job_title%TYPE
                                            );
    TYPE t_actual_information IS TABLE OF all_needed_information;
    FUNCTION get_higher_dept_salary(passed_id departments.department_id%TYPE) RETURN employees.salary%TYPE;
    FUNCTION get_higher_dept_salary(passed_id departments.department_id%TYPE, passed_job_id employees.job_id%TYPE) RETURN employees.salary%TYPE;
--Type for optional information
    TYPE v_opt_inf IS RECORD (f_name employees.first_name%TYPE,
                              l_name employees.last_name%TYPE,
                              d_name departments.department_name%TYPE,
                              j_title jobs.job_title%TYPE);
    TYPE t_opt_inf IS TABLE OF v_opt_inf;
END;
/
CREATE OR REPLACE PACKAGE BODY high_salary IS
    -- inicialize collect variable which will store neccesery information for both function
    temporary_information t_actual_information := t_actual_information(); 
     
 FUNCTION get_higher_dept_salary(passed_id departments.department_id%TYPE) RETURN employees.salary%TYPE IS
    higher_salary employees.salary%TYPE;
    v_optional t_opt_inf := high_salary.t_opt_inf();
     BEGIN
        --getting max salary from passed department
        SELECT MAX(salary) into higher_salary FROM TABLE(temporary_information) WHERE department_id = passed_id;    
        --optional information, i made it only for my exercise
        SELECT first_name, last_name, department_name, job_title bulk collect into v_optional 
        FROM TABLE(temporary_information) WHERE department_id = passed_id and salary = higher_salary;
            FOR i IN v_optional.FIRST..v_optional.LAST 
                LOOP   
                    DBMS_OUTPUT.PUT_LINE('Najwiêksz¹ pensje w dziale '||v_optional(i).d_name||' ma pracownik o imieniu: '
                    ||v_optional(i).f_name||' i nazwisku: '||v_optional(i).l_name||' pracujacy na stanowisku: ' ||v_optional(i).j_title);
                END LOOP;
    RETURN higher_salary;
    END get_higher_dept_salary; 

--function similar to preciding function, added job_id part, it return most higher salary for concrete department and occupation
FUNCTION get_higher_dept_salary(passed_id departments.department_id%TYPE, passed_job_id employees.job_id%TYPE) RETURN employees.salary%TYPE IS
    higher_salary employees.salary%TYPE;
    v_optional t_opt_inf := high_salary.t_opt_inf();
    BEGIN
        SELECT MAX(salary) into higher_salary FROM TABLE(temporary_information) WHERE department_id = passed_id AND job_id = passed_job_id;    
        SELECT first_name, last_name, department_name, job_title bulk collect into v_optional 
       
        FROM TABLE(temporary_information) WHERE department_id = passed_id and salary = higher_salary;
            FOR i IN v_optional.FIRST..v_optional.LAST 
                LOOP   
                    DBMS_OUTPUT.PUT_LINE('Najwiêksz¹ pensje w dziale '||v_optional(i).d_name||' ma pracownik o imieniu: '
                    ||v_optional(i).f_name||' i nazwisku: '||v_optional(i).l_name||' pracujacy na stanowisku: ' ||v_optional(i).j_title);
                END LOOP;
    RETURN higher_salary;
    END get_higher_dept_salary; 

BEGIN
--here it get information which both function need to right work
 SELECT employee_id,first_name, last_name, salary, emp.department_id, dep.department_name, emp.job_id, jobs.job_title
        BULK COLLECT INTO temporary_information
        FROM employees emp
        INNER JOIN departments dep ON emp.department_id = dep.department_id 
        INNER JOIN jobs ON emp.job_id = jobs.job_id;
END high_salary;
/
BEGIN
DBMS_OUTPUT.PUT_LINE(high_salary.get_higher_dept_salary(30));
DBMS_OUTPUT.PUT_LINE(high_salary.get_higher_dept_salary(90,'AD_'));
END;
/
SET SERVEROUTPUT ON;
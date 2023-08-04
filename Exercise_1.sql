create or replace PACKAGE program_to_manage_products IS
    PROCEDURE add_product(new_product_name VARCHAR2);
    PROCEDURE remove_product(id_product_to_remove NUMBER);
    PROCEDURE modify_product(id products.product_id%TYPE, new_lp products.lp%TYPE);
    FUNCTION get_all_information_of_product(id products.product_id%TYPE) RETURN VARCHAR2;
END program_to_manage_products;
/
create or replace PACKAGE BODY program_to_manage_products IS

--funcion will be returning if name of product already exists in table, i know that i could use constraint but i did it for own exercise:)
FUNCTION check_if_product_already_exists(new_product_name VARCHAR2) RETURN BOOLEAN IS
        number_of_the_same_products NUMBER := 0 ;
        exists_or_not BOOLEAN;
            BEGIN
                SELECT COUNT(*)INTO number_of_the_same_products FROM products WHERE UPPER(product_name) = UPPER(new_product_name); 
                    IF( number_of_the_same_products = 0) THEN RETURN FALSE;
                    ELSE RETURN TRUE;
                    END IF;
            END check_if_product_already_exists;

--Procedure will add new product if in table not exist product with the same name
PROCEDURE add_product (new_product_name VARCHAR2) IS 
    empty_text EXCEPTION; -- this exception will be pop up when user will try add value without text inside
    PRAGMA EXCEPTION_INIT (empty_text,-20002); 
    the_same_product_it_is_in_table EXCEPTION;  --this exception will be pop up when identical name of products exist
    PRAGMA EXCEPTION_INIT (the_same_product_it_is_in_table,-20001);
    v_primary_key NUMBER; 
        BEGIN
            IF (TRIM(new_product_name)IS NULL) THEN RAISE empty_text; 
            END IF;
            IF NOT(check_if_product_already_exists(new_product_name) = TRUE) THEN
                SELECT (MAX(product_id)+1) INTO v_primary_key FROM products; --assigment last added value of primary key and increase it by 1
                INSERT INTO products (product_id,product_name) VALUES (v_primary_key,new_product_name); --add new value to products table
                DBMS_OUTPUT.PUT_LINE('pomyslnie dodano rekord do tabelo');
            ELSE RAISE the_same_product_it_is_in_table;
            END IF;
        EXCEPTION
            WHEN the_same_product_it_is_in_table THEN DBMS_OUTPUT.PUT_LINE('Produkt o podanej nazwie juz istnieje w bazie');
            WHEN empty_text THEN DBMS_OUTPUT.PUT_LINE('Poda³eœ pusty tekst');
    END add_product;

--Procedure will remove product with id given by user after checked if that product are in table
PROCEDURE remove_product(id_product_to_remove NUMBER) IS
    name_of_product VARCHAR2(50); -- into this variable i put name of product to show what have changed, or if it find nothing it's mean that record with this id not exist
    if_product_exist BOOLEAN;
        BEGIN
            SELECT product_name INTO name_of_product FROM products WHERE product_id = id_product_to_remove;
            DELETE FROM products WHERE product_id = id_product_to_remove; 
                DBMS_OUTPUT.PUT_LINE('Usun³¹³eœ produkt o nazwie: '|| name_of_product);
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Wpisales niepoprawny kod id');
END remove_product;

--Procedure will be changing number of products avalible in store
PROCEDURE modify_product(id products.product_id%TYPE, new_lp products.lp%TYPE) IS
    TYPE rec_product_info IS RECORD (p_name products.product_name%TYPE
                       ,p_lp products.lp%TYPE);
    product_info rec_product_info;    
    BEGIN 
        SELECT product_name, lp INTO product_info FROM products WHERE product_id = id;
        UPDATE products SET LP = new_lp WHERE product_id = id;
        DBMS_OUTPUT.PUT_LINE('zmieni³eœ produkt o nazwie: ' || product_info.p_name || ' z iloœci '|| product_info.p_lp || ' na ' || new_lp);
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Wpisales niepoprawny kod id');
    END modify_product;

--this function could return %type of row from products but will easier for user when it return varchar, it can display only via DBMS_OUTPUT.PUT_LINE
FUNCTION get_all_information_of_product(id products.product_id%TYPE) RETURN VARCHAR2  IS
    check_if_record_exist NUMBER(1);
    p_id products.product_id%TYPE;
    p_name products.product_name%TYPE;
    p_lp products.lp%TYPE;
    all_information VARCHAR2(200);
    if_record_not_exist VARCHAR2(100);
        BEGIN
            --make a value when none will be find
            if_record_not_exist:= 'Nie ma w bazie rekordu o id wartosci: '|| id;
            
            --I read that is the one of the most efficienty way to check if record with particular id exist, so i gave it a chance here:) 
            SELECT 1 into check_if_record_exist 
            FROM products WHERE product_id= id 
            AND EXISTS (SELECT 1 FROM products where product_id = id);
            
            IF (check_if_record_exist = 1) THEN
                SELECT product_id, product_name, lp INTO p_id,p_name,p_lp FROM products WHERE product_id = id;
                all_information := 'Produkt o id: '|| p_id || ' nosi nazwe: ' || p_name ||', jest go na stanie: ' ||p_lp;
            ELSE all_information := 'Podales nie wlasciwy numer Id';
            END IF;
        RETURN all_information;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RETURN if_record_not_exist;
END get_all_information_of_product;

END program_to_manage_products;
/
GRANT EXECUTE ON program_to_manage_products TO hr;
/

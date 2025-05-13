CREATE TABLE public."role" (
	"role" varchar NOT NULL,
	CONSTRAINT role_pk PRIMARY KEY (role)
);

CREATE TABLE public.users (
	id serial4 NOT NULL,
	login varchar NOT NULL,
	"password" varchar NOT NULL,
	"name" varchar NULL,
	surname varchar NULL,
	"role" varchar NULL,
	CONSTRAINT users_pk PRIMARY KEY (id),
	CONSTRAINT users_role_fk FOREIGN KEY ("role") REFERENCES public."role"("role")
);


CREATE TABLE public.test (
	id serial4 NOT NULL,
	questions varchar NULL,
	CONSTRAINT test_pk PRIMARY KEY (id)
);


CREATE TABLE public.questions (
	id serial4 NOT NULL,
	"text" varchar NOT NULL,
	answer varchar NOT NULL,
	test serial4 NOT NULL,
	"key" int8 NULL,
	CONSTRAINT questions_pk PRIMARY KEY (id),
	CONSTRAINT questions_test_fk FOREIGN KEY (test) REFERENCES public.test(id)
);

CREATE TABLE public.answer (
	id serial4 NOT NULL,
	"text" varchar NULL,
	question serial4 NOT NULL,
	CONSTRAINT answer_pk PRIMARY KEY (id),
	CONSTRAINT answer_questions_fk FOREIGN KEY (question) REFERENCES public.questions(id)
);

//




//


CREATE OR REPLACE FUNCTION public.create_test(paramsin jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    new_id integer;
BEGIN
   
    INSERT INTO test (questions) 
    VALUES (NULL) 
    RETURNING id INTO new_id;
    
    
    RETURN jsonb_build_object('id', new_id);
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$
;
//


-- DROP FUNCTION public.delete_test(jsonb);

CREATE OR REPLACE FUNCTION public.delete_test(paramsin jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
BEGIN
    
    DELETE FROM test WHERE id = (paramsin->>'id')::integer;
    
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Test not found');
    END IF;
    
    
    RETURN jsonb_build_object('status', 'success');
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$
;

//

-- DROP FUNCTION public.create_question(jsonb);

CREATE OR REPLACE FUNCTION public.create_question(paramsin jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    new_id integer;
    test_id integer;
BEGIN
    
    test_id := (paramsin->>'test_id')::integer;
    
    
    IF NOT EXISTS (SELECT 1 FROM test WHERE id = test_id) THEN
        RETURN jsonb_build_object('error', 'Test not found');
    END IF;
    
    
    INSERT INTO questions (text, answer, test, key) 
    VALUES (
        paramsin->>'text',
        paramsin->>'answer',
        test_id,
        (paramsin->>'key')::bigint
    ) 
    RETURNING id INTO new_id;
    
    
    RETURN jsonb_build_object('id', new_id);
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$
;

//

CREATE OR REPLACE FUNCTION public.delete_question(paramsin jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
BEGIN
   
    DELETE FROM questions WHERE id = (paramsin->>'id')::integer;
    
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Question not found');
    END IF;
    
    
    RETURN jsonb_build_object('status', 'success');
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$
;

//

-- DROP FUNCTION public.create_answer(jsonb);

CREATE OR REPLACE FUNCTION public.create_answer(paramsin jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    new_id integer;
    question_id integer;
BEGIN
    
    question_id := (paramsin->>'question_id')::integer;
    
    
    IF NOT EXISTS (SELECT 1 FROM questions WHERE id = question_id) THEN
        RETURN jsonb_build_object('error', 'Question not found');
    END IF;
    
   
    IF paramsin->>'text' IS NULL THEN
        RETURN jsonb_build_object('error', 'Answer text is required');
    END IF;
    
   
    INSERT INTO answer (text, question)
    VALUES (
        paramsin->>'text',
        question_id
    )
    RETURNING id INTO new_id;
    
    
    RETURN jsonb_build_object('id', new_id);
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$
;

//


-- DROP FUNCTION public.delete_answer(jsonb);

CREATE OR REPLACE FUNCTION public.delete_answer(paramsin jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
BEGIN
    
    IF paramsin->>'id' IS NULL THEN
        RETURN jsonb_build_object('error', 'Answer ID is required');
    END IF;
    
    
    DELETE FROM answer WHERE id = (paramsin->>'id')::integer;
    
   
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Answer not found');
    END IF;
    
    
    RETURN jsonb_build_object('status', 'success');
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$
;


//


-- DROP FUNCTION public.get_test(jsonb);

CREATE OR REPLACE FUNCTION public.get_test(paramsin jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    test_id integer;
    test_data jsonb;
BEGIN

    test_id := (paramsin->>'id')::integer;
    

    IF NOT EXISTS (SELECT 1 FROM test WHERE id = test_id) THEN
        RETURN jsonb_build_object('error', 'Test not found');
    END IF;
    
    -- Формируем структуру теста с вопросами и ответами
    SELECT jsonb_build_object(
        'questions', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', q.id,
                    'text', q.text,
                    'answers', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', a.id,
                                'text', a.text
                            )
                        )
                        FROM answer a
                        WHERE a.question = q.id
                    )
                )
            )
            FROM questions q
            WHERE q.test = test_id
        )
    ) INTO test_data;
    
    -- Возвращаем результат
    RETURN test_data;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$
;


//


-- DROP FUNCTION public.auth_user(jsonb);

CREATE OR REPLACE FUNCTION public.auth_user(paramsin jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    user_login varchar;
    user_password varchar;
    user_role varchar;
    user_id integer;
    user_data jsonb;
BEGIN

    user_login := paramsin->>'login';
    user_password := paramsin->>'password';
    user_role := paramsin->>'role';
    

    IF user_login IS NULL OR user_password IS NULL OR user_role IS NULL THEN
        RETURN jsonb_build_object('error', 'Login, password and role are required');
    END IF;
    

    SELECT id INTO user_id
    FROM users
    WHERE login = user_login 
      AND password = user_password
      AND role = user_role;
    

    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Invalid login, password or role');
    END IF;
    

    SELECT jsonb_build_object(
        'id', id,
        'login', login,
        'name', name,
        'surname', surname,
        'role', role
    ) INTO user_data
    FROM users
    WHERE id = user_id;
    

    RETURN jsonb_build_object('user', user_data, 'status', 'success');
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$
;


//


CREATE OR REPLACE FUNCTION public.test_api(paramsin jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    operation text;
BEGIN
    operation := paramsin->>'Oper';
  
    CASE operation
        WHEN 'Create Test' THEN
            RETURN create_test(paramsin->'Params');
            
        WHEN 'Delete Test' THEN
            RETURN delete_test(paramsin->'Params');
            
        WHEN 'Create Question' THEN
            RETURN create_question(paramsin->'Params');
            
        WHEN 'Delete Question' THEN
            RETURN delete_question(paramsin->'Params');
            
        WHEN 'Create Answer' THEN
            RETURN create_answer(paramsin->'Params');
            
        WHEN 'Delete Answer' THEN
            RETURN delete_answer(paramsin->'Params');
            
        WHEN 'Get Test' THEN
            RETURN get_test(paramsin->'Params');
            
        WHEN 'Auth User' THEN
            RETURN auth_user(paramsin->'Params');
            
        ELSE
            RETURN jsonb_build_object('error', 'Unknown operation');
    END CASE;
END;
$function$
;
//



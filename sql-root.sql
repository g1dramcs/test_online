CREATE TABLE public."role" (
	"role" varchar NOT NULL,
	CONSTRAINT role_pk PRIMARY KEY (role)
);


CREATE TABLE public."groups" (
	id serial4 NOT NULL,
	"name" varchar NULL,
	CONSTRAINT groups_pk PRIMARY KEY (id)
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

CREATE TABLE public.subject (
	id serial4 NOT NULL,
	"name" varchar NULL,
	CONSTRAINT subjects_pk PRIMARY KEY (id)
);

CREATE TABLE public.test (
	id serial4 NOT NULL,
	questions varchar NULL,
	subject bigserial NOT NULL,
	CONSTRAINT test_pk PRIMARY KEY (id),
	CONSTRAINT test_subject_fk FOREIGN KEY (subject) REFERENCES public.subject(id)
);


CREATE TABLE public.questions (
	id serial4 NOT NULL,
	"text" varchar NOT NULL,
	answer varchar NULL,
	test serial4 NOT NULL,
	"key" int8 NULL,
	CONSTRAINT questions_pk PRIMARY KEY (id),
	CONSTRAINT questions_test_fk FOREIGN KEY (test) REFERENCES public.test(id) ON DELETE CASCADE
);


CREATE TABLE public.answer (
	id serial4 NOT NULL,
	"text" varchar NULL,
	question serial4 NOT NULL,
	correct bool DEFAULT false NOT NULL,
	CONSTRAINT answer_pk PRIMARY KEY (id),
	CONSTRAINT answer_questions_fk FOREIGN KEY (question) REFERENCES public.questions(id) ON DELETE CASCADE
);

CREATE TABLE public.user_answer (
	id serial4 NOT NULL,
	qestion_id bigserial NOT NULL,
	answer_id bigserial NOT NULL,
	user_id bigserial NOT NULL,
	CONSTRAINT user_answer_pk PRIMARY KEY (id),
	CONSTRAINT user_answer_answer_fk FOREIGN KEY (answer_id) REFERENCES public.answer(id),
	CONSTRAINT user_answer_questions_fk FOREIGN KEY (qestion_id) REFERENCES public.questions(id),
	CONSTRAINT user_answer_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id)
);


CREATE OR REPLACE FUNCTION public.create_test(paramsin jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    new_id integer;
    subject_id integer;
BEGIN
    subject_id := (paramsin->>'subject_id')::integer;
    IF NOT EXISTS (SELECT 1 FROM subject WHERE id = subject_id) THEN
        RETURN jsonb_build_object('error', 'Subject not found');
    END IF;

    INSERT INTO test (questions, subject) 
    VALUES (NULL, subject_id) 
    RETURNING id INTO new_id;
    
    RETURN jsonb_build_object('id', new_id);
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

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
$function$;

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
$function$;

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
$function$;

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
    
    INSERT INTO answer (text, question, correct) 
    VALUES (
        paramsin->>'text',
        question_id,
        (paramsin->>'correct')::boolean
    ) 
    RETURNING id INTO new_id;
    
    RETURN jsonb_build_object('id', new_id);
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

CREATE OR REPLACE FUNCTION public.delete_answer(paramsin jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
BEGIN
    DELETE FROM answer WHERE id = (paramsin->>'id')::integer;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Answer not found');
    END IF;
    
    RETURN jsonb_build_object('status', 'success');
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

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
    
    SELECT jsonb_build_object(
        'questions', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', q.id,
                    'text', q.text,
                    'answer', q.answer,
                    'key', q.key,
                    'answers', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', a.id,
                                'text', a.text,
                                'correct', a.correct
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
    
    RETURN test_data;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

CREATE OR REPLACE FUNCTION public.auth_user(paramsin jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    user_data jsonb;
BEGIN
    IF paramsin->>'login' IS NULL OR paramsin->>'password' IS NULL THEN
        RETURN jsonb_build_object('error', 'Login and password are required');
    END IF;
    
    SELECT jsonb_build_object(
        'id', id,
        'login', login,
        'name', name,
        'surname', surname,
        'role', role
    ) INTO user_data
    FROM users
    WHERE login = paramsin->>'login' 
      AND password = paramsin->>'password'
      AND role = paramsin->>'role';
    
    IF user_data IS NULL THEN
        RETURN jsonb_build_object('error', 'Invalid login or password');
    END IF;
    
    RETURN jsonb_build_object('user', user_data, 'status', 'success');
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

CREATE OR REPLACE FUNCTION public.create_user(paramsin jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    new_id integer;
BEGIN
    IF paramsin->>'login' IS NULL OR paramsin->>'password' IS NULL THEN
        RETURN jsonb_build_object('error', 'Login and password are required');
    END IF;
    
    IF paramsin->>'role' IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM role WHERE role = paramsin->>'role'
    ) THEN
        RETURN jsonb_build_object('error', 'Specified role does not exist');
    END IF;
    
    INSERT INTO users (login, password, name, surname, role)
    VALUES (
        paramsin->>'login',
        paramsin->>'password',
        paramsin->>'name',
        paramsin->>'surname',
        paramsin->>'role'
    )
    RETURNING id INTO new_id;
    
    RETURN jsonb_build_object('id', new_id);
EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object('error', 'User with this login already exists');
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_users(paramsin jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    users_data jsonb;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', u.id,
            'login', u.login,
            'name', u.name,
            'surname', u.surname,
            'role', u.role
        )
    ) INTO users_data
    FROM users u;
    
    IF users_data IS NULL THEN
        users_data := '[]'::jsonb;
    END IF;
    
    RETURN jsonb_build_object('users', users_data);
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_user(paramsin jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    user_data jsonb;
BEGIN
    IF paramsin->>'id' IS NULL THEN
        RETURN jsonb_build_object('error', 'User ID is required');
    END IF;
    
    SELECT jsonb_build_object(
        'id', id,
        'login', login,
        'name', name,
        'surname', surname,
        'role', role
    ) INTO user_data
    FROM users
    WHERE id = (paramsin->>'id')::integer;
    
    IF user_data IS NULL THEN
        RETURN jsonb_build_object('error', 'User not found');
    END IF;
    
    RETURN jsonb_build_object('user', user_data);
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

CREATE OR REPLACE FUNCTION public.set_user(paramsin jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
BEGIN
    IF paramsin->>'id' IS NULL THEN
        RETURN jsonb_build_object('error', 'User ID is required');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = (paramsin->>'id')::integer) THEN
        RETURN jsonb_build_object('error', 'User not found');
    END IF;
    
    IF paramsin->>'role' IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM role WHERE role = paramsin->>'role'
    ) THEN
        RETURN jsonb_build_object('error', 'Specified role does not exist');
    END IF;
    
    UPDATE users SET
        login = COALESCE(paramsin->>'login', login),
        password = COALESCE(paramsin->>'password', password),
        name = COALESCE(paramsin->>'name', name),
        surname = COALESCE(paramsin->>'surname', surname),
        role = COALESCE(paramsin->>'role', role)
    WHERE id = (paramsin->>'id')::integer;
    
    RETURN jsonb_build_object('status', 'success');
EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object('error', 'User with this login already exists');
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

CREATE OR REPLACE FUNCTION public.delete_user(paramsin jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
BEGIN
    IF paramsin->>'id' IS NULL THEN
        RETURN jsonb_build_object('error', 'User ID is required');
    END IF;
    
    DELETE FROM users WHERE id = (paramsin->>'id')::integer;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'User not found');
    END IF;
    
    RETURN jsonb_build_object('status', 'success');
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM);
END;
$function$;

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
        WHEN 'Get Users' THEN
            RETURN get_users(paramsin->'Params');
        WHEN 'Get User' THEN
            RETURN get_user(paramsin->'Params');
        WHEN 'Create User' THEN
            RETURN create_user(paramsin->'Params');
        WHEN 'Set User' THEN
            RETURN set_user(paramsin->'Params');
        WHEN 'Delete User' THEN
            RETURN delete_user(paramsin->'Params');
        ELSE
            RETURN jsonb_build_object('error', 'Unknown operation');
    END CASE;
END;
$function$;
import json
import pymysql
import os
import math

# RDS Connection Info
RDS_HOST = os.environ['RDS_HOST']
RDS_USER = os.environ['RDS_USERNAME']
RDS_PASSWORD = os.environ['RDS_PASSWORD']
RDS_DB_NAME = os.environ['RDS_DB_NAME']

# Connect to RDS MySQL
def get_db_connection():
    return pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD, database=RDS_DB_NAME)

def lambda_handler(event, context):
    connection = get_db_connection()

    # CORS Headers
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
    }

    try:
        print(f"Received event: {event}")

        # Parse the request body and validate inputs
        body = json.loads(event.get('body', '{}'))
        session_id = body.get('session_id')
        question_id = body.get('question_id')
        user_response = body.get('user_response')
        question_order = body.get('question_order')

        if not all([session_id, question_id, user_response, question_order]):
            return {
                'statusCode': 400,
                'headers': headers,
                'body': json.dumps({'error': 'Missing required input data'})
            }

        print(f"Parsed inputs - session_id: {session_id}, question_id: {question_id}, user_response: {user_response}, question_order: {question_order}")

        # Step 1: Insert the user's answer into the User_Answers table
        with connection.cursor() as cursor:
            cursor.execute(
                "INSERT INTO User_Answers (session_id, question_id, user_response, question_order) VALUES (%s, %s, %s, %s)",
                [session_id, question_id, user_response, question_order]
            )
            print(f"Inserted user answer successfully for session_id: {session_id}")

            # Step 2: Update the question statistics
            if user_response == 'Yes':
                cursor.execute("UPDATE Questions SET yes_count = yes_count + 1, times_asked = times_asked + 1 WHERE question_id = %s", [question_id])
            elif user_response == 'No':
                cursor.execute("UPDATE Questions SET no_count = no_count + 1, times_asked = times_asked + 1 WHERE question_id = %s", [question_id])
            print(f"Updated question stats for question_id: {question_id}")

            # Step 3: Calculate and update the entropy score
            cursor.execute("SELECT yes_count, no_count FROM Questions WHERE question_id = %s", [question_id])
            yes_count, no_count = cursor.fetchone()
            total = yes_count + no_count
            if total > 0:
                p_yes = yes_count / total
                p_no = no_count / total
                entropy = -(p_yes * math.log2(p_yes) + p_no * math.log2(p_no)) if p_yes > 0 and p_no > 0 else 0
                cursor.execute("UPDATE Questions SET entropy_score = %s WHERE question_id = %s", [entropy, question_id])
            print(f"Updated entropy score for question_id: {question_id}")

            # Step 4: Update the Character_Question_Map (CQM) table
            cursor.execute("""
                SELECT character_id 
                FROM Character_Question_Map 
                WHERE question_id = %s AND session_id = %s
            """, [question_id, session_id])
            existing_cqm = cursor.fetchall()

            if not existing_cqm:
                # No entry exists for this question in the session, insert it
                cursor.execute("""
                    INSERT INTO Character_Question_Map (character_id, question_id, session_id, answer, weight, is_flagged, date_created, creating_player_id)
                    SELECT character_id, %s, %s, %s, 1, 0, NOW(), 1
                    FROM Characters
                """, [question_id, session_id, user_response])
                print(f"Inserted into Character_Question_Map for question_id: {question_id} and session_id: {session_id}")

            # Step 5: Fetch the next question or guess a character based on user responses
            cursor.execute("""
                SELECT character_id, COUNT(*) as match_count
                FROM Character_Question_Map 
                WHERE question_id = %s AND answer = %s
                GROUP BY character_id
                ORDER BY match_count DESC
                LIMIT 1
            """, [question_id, user_response])

            character_match = cursor.fetchone()
            if character_match:
                character_id = character_match[0]
                cursor.execute("SELECT character_name FROM Characters WHERE character_id = %s", [character_id])
                guessed_character = cursor.fetchone()[0]

                print(f"Guessed character: {guessed_character}")
                return {
                    'statusCode': 200,
                    'headers': headers,
                    'body': json.dumps({'guessed_character': guessed_character})
                }
            else:
                # Fetch the next question based on the highest entropy score
                cursor.execute("SELECT question_id, question_text FROM Questions ORDER BY entropy_score DESC LIMIT 1")
                next_question = cursor.fetchone()

                if next_question:
                    next_question_id, next_question_text = next_question
                    print(f"Next question: {next_question_text}")
                    return {
                        'statusCode': 200,
                        'headers': headers,
                        'body': json.dumps({
                            'next_question': {
                                'question_id': next_question_id,
                                'question_text': next_question_text
                            }
                        })
                    }
                else:
                    return {
                        'statusCode': 200,
                        'headers': headers,
                        'body': json.dumps({'message': 'No more questions to ask'})
                    }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        connection.close()

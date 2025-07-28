from firebase_functions import https_fn, options
from firebase_admin import initialize_app
import google.generativeai as genai
from firebase_functions.params import SecretParam
initialize_app()

options.set_global_options(
    region=options.SupportedRegion.US_EAST1,
    max_instances=5
)

GEMINI_API_KEY = SecretParam("GEMINI_API_KEY")

@https_fn.on_call(secrets=[GEMINI_API_KEY])
def get_task_motivation(req: https_fn.Request) -> https_fn.Response:
    """Gets a motivational message for a specific task."""
    
    try:
        genai.configure(api_key=GEMINI_API_KEY.value)
        model = genai.GenerativeModel('gemini-2.5-flash')
        print(f'req: {req}')
        print(f'req.data: {req.data}')
        task_data = req.data
        task_name = task_data.get("name", "Unnamed Task")
        task_description = task_data.get("description", "")
        due_date = task_data.get("dueDate", "No due date")

        prompt = f"""
        You are a world-class productivity coach named Gemini. A user is about to start a task. 
        Based on the following details, provide a short, powerful, and encouraging paragraph (2-3 sentences max) to motivate them to start. 
        Frame it directly to the user in a friendly tone.

        Task Name: {task_name}
        Description: {task_description}
        Due Date: {due_date}
        """

        response = model.generate_content(prompt)
        print(response)
        # ✅ This is the corrected return statement with the real AI response.
        return {"motivationText": response.text}

    except Exception as e:
        print(f"An error occurred: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message="An error occurred while generating motivation."
        )
    # In functions/main.py

# ... your existing get_task_motivation function ...

@https_fn.on_call(secrets=[GEMINI_API_KEY])
def get_task_breakdown(req: https_fn.Request) -> https_fn.Response:
    """Breaks a task down into actionable steps."""
    
    try:
        genai.configure(api_key=GEMINI_API_KEY.value)
        model = genai.GenerativeModel('gemini-1.5-flash')

        task_data = req.data
        task_name = task_data.get("name", "Unnamed Task")
        task_description = task_data.get("description", "")

        prompt = f"""
        You are a world-class productivity coach. A user is feeling overwhelmed by a task. 
        Based on the following details, break this task down into 3 simple, actionable first steps to help them get started.
        Present the steps as a list separated by the newline character '\n'. Do not use numbers or bullet points.

        Task Name: {task_name}
        Description: {task_description}
        """

        response = model.generate_content(prompt)
        
        # We split the response into an array of strings
        steps = response.text.strip().split('\n')
        
        return {"steps": steps}

    except Exception as e:
        print(f"An error occurred: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message="An error occurred while generating breakdown."
        )
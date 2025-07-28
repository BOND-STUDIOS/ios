from firebase_functions import https_fn, options
from firebase_admin import initialize_app
import google.generativeai as genai
from firebase_functions.params import SecretParam

import json
import uuid
from enum import Enum
from datetime import date
from pydantic import BaseModel, Field
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
 


class EnergyLevel(str, Enum):
    DEEP = 'Deep Work'
    SHALLOW = 'Shallow Work'
    RECHARGE = 'Recharge'

class Task(BaseModel):
    id: str = Field(description='unique id of the task', default_factory=lambda: str(uuid.uuid4()))
    title: str = Field(description='title of the task')
    description: str = Field(description='description of the task')
    isCompleted: bool = Field(description='is the task completed', default=False)
    dueDate: str = Field(description='due date of the task in YYYY-MM-DD HH:MM format')
    energyLevel: EnergyLevel = Field(description='energy level of the task; one of Deep Work, Shallow Work, or Recharge')
  


@https_fn.on_call(secrets=[GEMINI_API_KEY])
def ls(req: https_fn.Request) -> dict:
    """Generates a structured task object from a natural language string."""
    
    current_date = date.today().isoformat()
    try:
        genai.configure(api_key=GEMINI_API_KEY.value)
        
        user_input = req.data
        if not isinstance(user_input, str):
            raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
                                      message="Request data must be a string.")

        prompt = f"""
        For context, today's date is {current_date}.
        Analyze the user input and extract the details for a new task.
        The due date must be in YYYY-MM-DD HH:MM format.
        If no description is provided, create a brief one based on the title.
        
        User Input: "{user_input}"
        """

        model = genai.GenerativeModel(
            'gemini-1.5-flash',
            generation_config={"response_mime_type": "application/json"},
            tools=[Task]
        )
        
        response = model.generate_content(prompt)
        
        task_dict = json.loads(response.text)
        
        return task_dict

    except Exception as e:
        print(f"An error occurred: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message="An error occurred while generating the task."
        )
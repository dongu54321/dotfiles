import argparse
from openai import OpenAI

def get_ai_response(api_key, base_url, model, prompt, system_message=None):
    """
    Get response from AI model
    
    Args:
        api_key (str): API key for authentication
        base_url (str): Base URL for the API
        model (str): Model to use
        prompt (str): User prompt
        system_message (str, optional): System message to set context
    
    Returns:
        str: AI response
    """
    client = OpenAI(
        api_key=api_key,
        base_url=base_url
    )
    
    messages = []
    if system_message:
        messages.append({"role": "system", "content": system_message})
    messages.append({"role": "user", "content": prompt})
    
    try:
        response = client.chat.completions.create(
            model=model,
            messages=messages
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"Error: {str(e)}"

def main():
    parser = argparse.ArgumentParser(description="Get AI chat response")
    parser.add_argument("--api-key", required=True, help="API key for authentication")
    parser.add_argument("--base-url", required=True, help="Base URL for the API")
    parser.add_argument("--model", required=True, help="Model to use")
    parser.add_argument("--prompt", required=True, help="User prompt")
    parser.add_argument("--system-message", help="System message to set context")
    
    args = parser.parse_args()
    
    response = get_ai_response(
        api_key=args.api_key,
        base_url=args.base_url,
        model=args.model,
        prompt=args.prompt,
        system_message=args.system_message
    )
    
    print(response)

if __name__ == "__main__":
    main()
#from vapi_python import Vapi
import os
from dotenv import load_dotenv

load_dotenv()

class VapiManager:
    def __init__(self):
        self.client = vapi.Client(api_key=os.getenv('VAPI_API_KEY'))

    def generate_voice_response(self, text, voice_characteristics):
        try:
            response = self.client.synthesize(
                text=text,
                voice_id=voice_characteristics.get('voice_id', 'en-US-Neural2-J'),
                audio_format="mp3",
                speed=voice_characteristics.get('speed', 1.0),
                pitch=voice_characteristics.get('pitch', 0.0),
                # Add other parameters as supported by Vapi.ai
            )
            return response.content
        except Exception as e:
            print(f"Error generating voice response: {e}")
            return None 
from flask import Flask, request, jsonify
import google.generativeai as genai
from deepgram import Deepgram
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Initialize Gemini
genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))
model = genai.GenerativeModel('gemini-1.5-pro-latest')

# Initialize Deepgram
deepgram = Deepgram(os.getenv('DEEPGRAM_API_KEY'))

@app.route('/analyze_profile', methods=['POST'])
def analyze_profile():
    images = request.files.getlist('images')
    
    # Process images and create a prompt for Gemini
    prompt = "Analyze these LinkedIn profile screenshots and provide a summary of the person's professional background, skills, and potential pain points that our enterprise marketing automation tool could address."
    
    # Call Gemini API
    response = model.generate_content([prompt, images])
    
    return jsonify({'analysis': response.text})

@app.route('/transcribe_audio', methods=['POST'])
def transcribe_audio():
    audio_file = request.files['audio']
    
    # Call Deepgram API for transcription
    options = {"punctuate": True, "model": "general", "language": "en-US"}
    source = {'buffer': audio_file, 'mimetype': 'audio/wav'}
    response = deepgram.transcription.sync_prerecorded(source, options)
    
    transcript = response['results']['channels'][0]['alternatives'][0]['transcript']
    
    return jsonify({'transcript': transcript})

@app.route('/simulate_conversation', methods=['POST'])
def simulate_conversation():
    user_input = request.json['user_input']
    conversation_history = request.json['conversation_history']
    
    # Prepare prompt for Gemini
    prompt = f"You are an AI sales prospect. Respond to the following message from a salesperson: {user_input}\n\nConversation history:\n{conversation_history}"
    
    # Call Gemini API
    response = model.generate_content(prompt)
    
    return jsonify({'ai_response': response.text})

if __name__ == '__main__':
    app.run(debug=True)
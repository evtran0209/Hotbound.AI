from flask import Flask, request, jsonify, send_file
import google.generativeai as genai
from deepgram import Deepgram
import os
from dotenv import load_dotenv
from db_operations import DatabaseManager
from vapi_operations import VapiManager
import time
import io

load_dotenv()

app = Flask(__name__)

# Initialize Gemini
genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))
model = genai.GenerativeModel('gemini-1.5-pro-latest')

# Initialize Deepgram
deepgram = Deepgram(os.getenv('DEEPGRAM_API_KEY'))

# Initialize DatabaseManager
db_manager = DatabaseManager()

# Initialize VapiManager
vapi_manager = VapiManager()

@app.route('/analyze_profile', methods=['POST'])
def analyze_profile():
    images = request.files.getlist('images')
    
    # Process images and create a prompt for Gemini
    prompt = "Analyze these LinkedIn profile screenshots and provide a summary of the person's professional background, skills, education, and potential pain points that our enterprise marketing automation tool could address."
    
    # Call Gemini API
    response = model.generate_content([prompt, images])
    
    # Store the analysis in the database
    timestamp = int(time.time())
    db_manager.add_gemini_analysis(
        response.text,
        {"timestamp": timestamp, "prompt": prompt}
    )
    
    return jsonify({'analysis': response.text})

@app.route('/transcribe_audio', methods=['POST'])
def transcribe_audio():
    audio_file = request.files['audio']
    
    # Call Deepgram API for transcription
    options = {"punctuate": True, "model": "general", "language": "en-US"}
    source = {'buffer': audio_file, 'mimetype': 'audio/wav'}
    response = deepgram.transcription.sync_prerecorded(source, options)
    
    transcript = response['results']['channels'][0]['alternatives'][0]['transcript']
    
    # Store the transcript in the database
    timestamp = int(time.time())
    db_manager.add_deepgram_transcript(
        transcript,
        {"timestamp": timestamp, "audio_file": audio_file.filename}
    )
    
    return jsonify({'transcript': transcript})

@app.route('/simulate_conversation', methods=['POST'])
def simulate_conversation():
    user_input = request.json['user_input']
    conversation_history = request.json['conversation_history']
    
    # Get relevant context from the database
    context = db_manager.get_relevant_context(user_input)
    
    # Extract voice characteristics from context
    voice_characteristics = extract_voice_characteristics(context)
    
    # Prepare prompt for Gemini
    prompt = f"""You are an AI sales prospect. Use the following context to inform your response:

    {context}

    Respond to the following message from a salesperson: {user_input}

    Conversation history:
    {conversation_history}
    """
    
    # Call Gemini API
    response = model.generate_content(prompt)
    
    # Store the conversation in the database
    timestamp = int(time.time())
    db_manager.add_gemini_analysis(
        response.text,
        {"timestamp": timestamp, "prompt": prompt, "user_input": user_input}
    )
    
    # Generate voice response using extracted characteristics
    audio_content = vapi_manager.generate_voice_response(response.text, voice_characteristics)
    
    if audio_content:
        # Create an in-memory file-like object
        audio_file = io.BytesIO(audio_content)
        
        # Return the audio file
        return send_file(
            audio_file,
            mimetype='audio/mpeg',
            as_attachment=True,
            download_name='response.mp3'
        )
    else:
        return jsonify({'error': 'Failed to generate voice response'}), 500

@app.route('/query_data', methods=['POST'])
def query_data():
    query = request.json['query']
    n_results = request.json.get('n_results', 5)
    
    results = db_manager.query_data(query, n_results)
    
    return jsonify(results)

def extract_voice_characteristics(context):
    # This function would analyze the context and extract relevant voice characteristics
    # For example, age, gender, accent, etc.
    # This is a placeholder and would need to be implemented based on your specific needs
    return {
        "voice_id": "en-US-Neural2-J",  # Default voice ID
        "speed": 1.0,
        "pitch": 0.0,
        # Add other characteristics as needed
    }

if __name__ == '__main__':
    app.run(debug=True)
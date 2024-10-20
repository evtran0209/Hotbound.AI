from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os
from PIL import Image
import pillow_heif
import google.generativeai as genai
import base64
import io
from deepgram import Deepgram
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Configure upload folders and allowed extensions
IMAGE_UPLOAD_FOLDER = 'image_uploads'
AUDIO_UPLOAD_FOLDER = 'audio_uploads'
ALLOWED_IMAGE_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp', 'heic', 'heif'}
ALLOWED_AUDIO_EXTENSIONS = {'mp3', 'mp4', 'm4a', 'aac', 'wav', 'flac', 'pcm', 'ogg', 'opus', 'webm'}

app.config['IMAGE_UPLOAD_FOLDER'] = IMAGE_UPLOAD_FOLDER
app.config['AUDIO_UPLOAD_FOLDER'] = AUDIO_UPLOAD_FOLDER

# Ensure the upload folders exist
os.makedirs(IMAGE_UPLOAD_FOLDER, exist_ok=True)
os.makedirs(AUDIO_UPLOAD_FOLDER, exist_ok=True)

# Configure Google Gemini API
GOOGLE_API_KEY = os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=GOOGLE_API_KEY)
model = genai.GenerativeModel('gemini-1.5-pro')

# Configure Deepgram API
DEEPGRAM_API_KEY = os.getenv('DEEPGRAM_API_KEY')
deepgram = Deepgram(DEEPGRAM_API_KEY)

def allowed_image_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_IMAGE_EXTENSIONS

def allowed_audio_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_AUDIO_EXTENSIONS

def process_image(file_path):
    if file_path.lower().endswith(('.heic', '.heif')):
        heif_file = pillow_heif.read_heif(file_path)
        image = Image.frombytes(
            heif_file.mode,
            heif_file.size,
            heif_file.data,
            "raw",
            heif_file.mode,
            heif_file.stride,
        )
    else:
        image = Image.open(file_path)
    
    # Convert image to base64
    buffered = io.BytesIO()
    image.save(buffered, format="PNG")
    return base64.b64encode(buffered.getvalue()).decode('utf-8')

@app.route('/upload_images', methods=['POST'])
def upload_images():
    if 'files' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    files = request.files.getlist('files')
    
    if not files or files[0].filename == '':
        return jsonify({'error': 'No selected files'}), 400
    
    results = []
    
    for file in files:
        if file and allowed_image_file(file.filename):
            filename = secure_filename(file.filename)
            file_path = os.path.join(app.config['IMAGE_UPLOAD_FOLDER'], filename)
            file.save(file_path)
            
            try:
                # Process the image
                image_base64 = process_image(file_path)
                
                # Generate content using Gemini
                response1 = model.generate_content([
                    """Hi, I'm a salesperson trying to get more relevant information on my clients and prospects to help me connect with them better to close more deals. I'd like you to extract relevant information from this image and give it back to me in an easily digestible array of JSON objects (with the template given below).
                    For each piece of information I'd like you to justify why it is relevant and will help me connect to my client or prospect.
                    [
                        {
                            "<Unique ID>": "...",
                            "information": "...",
                            "justification": "...",
                            "confidence_score": "...",
                            "relevance_score": "..."
                        }
                    ]
                    
                    Please be brief and succinct in your response. PLEASE MAKE SURE YOUR OUTPUT IS VALID JSON. THIS IS VERY IMPORTANT. If you do well I will give you $20""",
                    {"mime_type": "image/jpeg", "data": image_base64}
                ])
                
                response2 = model.generate_content([
                    """Hi, please develop the prospect persona, that I will cold call as a salesperson, based on the relevant information extracted from this image. 
                    The persona will act as if they were this persona and refer to the relavant information extracted about themselves when it is relevant in the sales call. 
                    Please use the relevant infromation extracted from this image to make the voice agent talk, converse, ask question, and answer question as if they were this person we pulled this information about. 
                    For example, their professional experience, skills, education, and volunteer experience will determine how they make an objection or concur with a specific conversation point or if they feel confident or unsure about a deal brought up in the sales call.
                    Please make sure that you know that youb are the prospect persona and NOT the salesperson. The relevant information extracted from the image about you is for you to know how to respond and act in a sales call with a salesperson. 
                    THIS IS VERY IMPORTANT THAT YOU SHOULD NOT REPEAT the simulated sales conversation transcript you output here on the real time sales call, but rather use it to train youself on how you would the prospect on a sales call with a salesperson.
                    Please be brief and succinct in your response. THIS IS VERY IMPORTANT. If you do well I will give you $20""",
                    {"mime_type": "image/jpeg", "data": image_base64}
                ])
                # Convert Gemini response to JSON
                result = {
                    'filename': filename,
                    'prospect_analysis': response1.text,
                    'vapi_persona': response2.text
                }
                
                results.append(result)
            except Exception as e:
                results.append({'filename': filename, 'error': f'Error processing image: {str(e)}'})
        else:
            results.append({'filename': file.filename, 'error': 'File type not allowed'})
    
    return jsonify(results), 200

@app.route('/upload_audio', methods=['POST'])
async def upload_audio():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file and allowed_audio_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['AUDIO_UPLOAD_FOLDER'], filename)
        file.save(file_path)
        
        try:
            # Process the audio file with Deepgram
            with open(file_path, 'rb') as audio:
                source = {'buffer': audio, 'mimetype': file.content_type}
                response = await deepgram.transcription.prerecorded(source, {'smart_format': True, 'model': 'general'})
            
            # Extract the transcription
            transcription = response['results']['channels'][0]['alternatives'][0]['transcript']
            
            result = {
                'filename': filename,
                'transcription': transcription,
            }
            
            return jsonify(result), 200
        except Exception as e:
            return jsonify({'error': f'Error processing audio: {str(e)}'}), 500
    
    return jsonify({'error': 'File type not allowed'}), 400

if __name__ == '__main__':
    app.run(debug=True)
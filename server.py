from flask import Flask, request, jsonify
from vector_embedding import generate_embedding

app = Flask(__name__)

@app.route('/receive-data', methods=['POST'])
def receive_data():
    # Parse JSON data sent by the client
    data = request.get_json()
    if not data or 'content' not in data:
        return jsonify({"error": "No 'content' field in JSON data"}), 400
    
    original_content = data['content']
    
    # Generate vector embedding for the content
    try:
        embedding = generate_embedding(original_content)
        return jsonify({
            "content": original_content,
            "embedding": embedding
        }), 200
    except Exception as e:
        return jsonify({"error": f"Error generating embedding: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=True)

from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/run-script', methods=['GET'])
def run_script():
    name = request.args.get('name', 'World')
    
    try:
        # Run the hello_world.sh script with the name parameter
        result = subprocess.run(['bash', '/scripts/hello_world.sh', name], capture_output=True, text=True, check=True)
        
        # Get the output and return it
        return jsonify({
            'output': result.stdout.strip(),
            'error': result.stderr.strip(),
            'returncode': result.returncode
        })
    except subprocess.CalledProcessError as e:
        # Handle errors in the called script
        return jsonify({
            'output': e.stdout.strip(),
            'error': e.stderr.strip(),
            'returncode': e.returncode
        }), 500

@app.route('/greet', methods=['POST'])
def greet():
    data = request.get_json()
    name = data.get('name', 'World')
    age = str(data.get('age', 'unknown'))
    
    try:
        # Run the greet.sh script with the name and age parameters
        result = subprocess.run(['bash', '/scripts/greet.sh', name, age], capture_output=True, text=True, check=True)
        
        # Get the output and return it
        return jsonify({
            'output': result.stdout.strip(),
            'error': result.stderr.strip(),
            'returncode': result.returncode
        })
    except subprocess.CalledProcessError as e:
        # Handle errors in the called script
        return jsonify({
            'output': e.stdout.strip(),
            'error': e.stderr.strip(),
            'returncode': e.returncode
        }), 500

@app.route('/tx', methods=['POST'])
def tx():
    data = request.get_json()
    TxIn = data.get('TxIn', 'unknown')
    
    try:
        # Run the tx.sh script with the TxIn parameters
        result = subprocess.run(['bash', '/scripts/tx.sh', TxIn], capture_output=True, text=True, check=True)
        
        # Get the output and return it
        return jsonify({
            'output': result.stdout.strip(),
            'error': result.stderr.strip(),
            'returncode': result.returncode
        })
    except subprocess.CalledProcessError as e:
        # Handle errors in the called script
        return jsonify({
            'output': e.stdout.strip(),
            'error': e.stderr.strip(),
            'returncode': e.returncode
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
"""
Simple script to start the API server with first-time setup
"""

import subprocess
import sys
import os
import json

def check_api_keys():
    """Check if API keys exist, if not guide user"""
    if not os.path.exists("api_keys.json"):
        print("\n" + "=" * 60)
        print("🔑 FIRST TIME SETUP - API KEY GENERATION")
        print("=" * 60)
        print("\nNo API keys found. Let's create one!\n")
        
        name = input("Enter a name for your API key (e.g., 'Flutter App'): ").strip()
        if not name:
            name = "Flutter App"
        
        description = input("Enter description (optional): ").strip()
        
        # Create a simple API key
        import secrets
        from datetime import datetime
        
        api_key = f"mea_{secrets.token_urlsafe(32)}"
        
        api_keys = {
            api_key: {
                "name": name,
                "description": description,
                "created_at": datetime.now().isoformat(),
                "last_used": None,
                "request_count": 0,
                "active": True
            }
        }
        
        with open("api_keys.json", "w") as f:
            json.dump(api_keys, f, indent=2)
        
        print("\n" + "=" * 60)
        print("✅ API KEY GENERATED!")
        print("=" * 60)
        print(f"\nYour API Key: {api_key}")
        print("\n⚠️  IMPORTANT:")
        print("1. Save this key securely!")
        print("2. Add it to your Flutter app:")
        print(f"   apiKey: '{api_key}'")
        print("3. This key is saved in api_keys.json")
        print("\n" + "=" * 60 + "\n")
        
        input("Press Enter to continue...")
        return api_key
    else:
        print("✅ API keys file found")
        # Show existing keys
        with open("api_keys.json", "r") as f:
            keys = json.load(f)
        
        print("\n📋 Existing API Keys:")
        for key, data in keys.items():
            if data.get("active", False):
                print(f"   - {data['name']}: {key}")
        print()
        
        return None


def get_local_ip():
    """Get local IP address"""
    import socket
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "localhost"


def main():
    print("🚀 Malaysian Employment Assistant - API Server Starter")
    print("=" * 60)
    
    # Check if we're in the backend directory
    if os.path.basename(os.getcwd()) != "backend":
        if os.path.exists("backend"):
            os.chdir("backend")
            print("📁 Changed to backend directory")
        else:
            print("❌ Error: backend folder not found!")
            print("   Please run this script from the FYP or backend directory")
            return
    
    # Check if model needs to be downloaded
    print("\n📦 Checking dependencies...")
    print("   (First run will download ~7GB model)")
    
    # Check API keys
    api_key = check_api_keys()
    
    # Get IP address
    local_ip = get_local_ip()
    
    print("\n🌐 Starting server...")
    print("=" * 60)
    print("\n📡 Server will be available at:")
    print(f"   - Local: http://localhost:8000")
    print(f"   - Network: http://{local_ip}:8000")
    print("\n📚 API Documentation at:")
    print(f"   - Swagger UI: http://localhost:8000/docs")
    print(f"   - ReDoc: http://localhost:8000/redoc")
    print("\n💡 For Flutter app, use:")
    print(f"   baseUrl: 'http://{local_ip}:8000'")
    if api_key:
        print(f"   apiKey: '{api_key}'")
    print("\n⏹️  Press CTRL+C to stop server")
    print("\n" + "=" * 60 + "\n")
    
    # Start server
    try:
        subprocess.run([
            sys.executable, "-m", "uvicorn",
            "llm_api_server:app",
            "--host", "0.0.0.0",
            "--port", "8000",
            "--reload"
        ])
    except KeyboardInterrupt:
        print("\n\n👋 Server stopped. Goodbye!")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\n💡 Make sure you have installed all requirements:")
        print("   pip install -r requirements.txt")


if __name__ == "__main__":
    main()
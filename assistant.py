import os
import requests
from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, FileResponse
from pydantic import BaseModel

app = FastAPI(title="Asistente IA Local", version="1.0")

OLLAMA_API = "http://localhost:11434/api/generate"
MODEL = os.getenv("MODEL_NAME", "qwen2.5:1.5b")
SHARED_DIR = "/shared"
APP_DIR = "/app"

class Query(BaseModel):
    prompt: str
    use_files: bool = False

# Servir interfaz web en la raíz
@app.get("/", response_class=HTMLResponse)
async def root():
    html_path = os.path.join(APP_DIR, "index.html")
    if os.path.exists(html_path):
        with open(html_path, "r", encoding="utf-8") as f:
            return HTMLResponse(content=f.read())
    return {"message": "Asistente API activo. Usa POST /ask para consultar."}

@app.get("/health")
def health():
    return {
        "status": "ok",
        "model": MODEL,
        "shared_folder": os.path.basename(SHARED_DIR),
        "shared_path": SHARED_DIR
    }

@app.post("/ask")
def ask(query: Query):
    payload = {"model": MODEL, "prompt": query.prompt, "stream": False}

    if query.use_files and os.path.isdir(SHARED_DIR):
        context_parts = []
        for fname in sorted(os.listdir(SHARED_DIR)):
            fpath = os.path.join(SHARED_DIR, fname)
            if os.path.isfile(fpath):
                try:
                    with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                        if len(content) < 50000:  # Límite de 50KB por archivo
                            context_parts.append(f"📄 {fname}:\n{content}")
                except Exception:
                    continue
        if context_parts:
            payload["prompt"] = f"📋 CONTEXTO DE ARCHIVOS:\n\n{'\n\n---\n\n'.join(context_parts)}\n\n❓ PREGUNTA DEL USUARIO:\n{query.prompt}"

    try:
        resp = requests.post(OLLAMA_API, json=payload, timeout=180)
        resp.raise_for_status()
        return {"response": resp.json().get("response", "")}
    except requests.exceptions.Timeout:
        raise HTTPException(status_code=504, detail="Timeout: el modelo tardó demasiado en responder")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080, log_level="info")

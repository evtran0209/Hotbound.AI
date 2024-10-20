import chromadb
from chromadb.config import Settings
import json

class DatabaseManager:
    def __init__(self):
        self.client = chromadb.Client(Settings(
            chroma_db_impl="duckdb+parquet",
            persist_directory="./chroma_db"
        ))
        self.collection = self.client.get_or_create_collection("hotbound_data")

    def add_deepgram_transcript(self, transcript, metadata):
        self.collection.add(
            documents=[transcript],
            metadatas=[{"type": "deepgram", **metadata}],
            ids=[f"deepgram_{metadata['timestamp']}"]
        )

    def add_gemini_analysis(self, analysis, metadata):
        self.collection.add(
            documents=[analysis],
            metadatas=[{"type": "gemini", **metadata}],
            ids=[f"gemini_{metadata['timestamp']}"]
        )

    def query_data(self, query_text, n_results=5):
        results = self.collection.query(
            query_texts=[query_text],
            n_results=n_results
        )
        return results

    def get_relevant_context(self, query, n_results=3):
        results = self.collection.query(
            query_texts=[query],
            n_results=n_results
        )
        context = ""
        for doc, metadata in zip(results['documents'][0], results['metadatas'][0]):
            context += f"Type: {metadata['type']}\n"
            context += f"Content: {doc}\n\n"
        return context
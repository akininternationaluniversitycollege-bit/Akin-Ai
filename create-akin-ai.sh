#!/bin/bash

# === Akin AI - One-Click Setup ===
# Creates a full Next.js + Groq + Llama 3 chat app
# Author: Your AI Assistant
# Usage: chmod +x create-akin-ai.sh && ./create-akin-ai.sh

echo "🚀 Setting up Akin AI..."

# Create project folder
mkdir -p akin-ai/app
cd akin-ai

# Create package.json
cat > package.json <<EOF
{
  "name": "akin-ai",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "14.2.3",
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "groq-sdk": "^0.4.0"
  },
  "devDependencies": {
    "@types/node": "20",
    "@types/react": "18",
    "@types/react-dom": "18",
    "typescript": "5",
    "tailwindcss": "3.4.3",
    "postcss": "8",
    "autoprefixer": "10"
  }
}
EOF

# Initialize git (optional)
git init -q

# Create tsconfig.json
cat > tsconfig.json <<EOF
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["app/**/*", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

# Create Tailwind config
npx tailwindcss init -p 2>/dev/null

cat > tailwind.config.ts <<EOF
import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
};
export default config;
EOF

cat > postcss.config.js <<EOF
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Create globals.css
mkdir -p app
cat > app/globals.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  background-color: #0f172a;
  color: #e2e8f0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

::-webkit-scrollbar {
  width: 6px;
}
::-webkit-scrollbar-track {
  background: #1e293b;
}
::-webkit-scrollbar-thumb {
  background: #334155;
  border-radius: 3px;
}
EOF

# Create layout.tsx
cat > app/layout.tsx <<'EOF'
import './globals.css';
import type { Metadata } from 'next';

export const meta Metadata = {
  title: 'Akin AI',
  description: 'Your kindred AI assistant',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
EOF

# Create page.tsx
cat > app/page.tsx <<'EOF'
'use client';

import { useState, useRef, useEffect } from 'react';

type Message = {
  id: string;
  role: 'user' | 'assistant';
  content: string;
};

export default function AkinAI() {
  const [input, setInput] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<null | HTMLDivElement>(null);

  useEffect(() => {
    const saved = localStorage.getItem('akin_messages');
    if (saved) setMessages(JSON.parse(saved));
  }, []);

  useEffect(() => {
    localStorage.setItem('akin_messages', JSON.stringify(messages));
  }, [messages]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input,
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: input }),
      });

      if (!response.ok) throw new Error('AI request failed');

      const data = await response.json();
      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: data.reply,
      };

      setMessages((prev) => [...prev, aiMessage]);
    } catch (error) {
      console.error(error);
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: '⚠️ Oops! Something went wrong. Please try again.',
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
  };

  return (
    <div className="flex flex-col min-h-screen max-w-4xl mx-auto px-4 py-8">
      <header className="mb-8 text-center">
        <h1 className="text-3xl font-bold bg-gradient-to-r from-teal-400 to-blue-500 text-transparent bg-clip-text">
          Akin AI
        </h1>
        <p className="text-sm text-gray-400 mt-1">
          Your kindred mind, powered by Llama 3
        </p>
      </header>

      <div className="flex-1 overflow-y-auto mb-6 space-y-6">
        {messages.length === 0 ? (
          <div className="text-center text-gray-500 mt-12">
            <p>Ask me anything!</p>
            <p className="text-xs mt-2">e.g., "Explain black holes like I'm 10"</p>
          </div>
        ) : (
          messages.map((msg) => (
            <div
              key={msg.id}
              className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-[85%] rounded-2xl px-4 py-3 ${
                  msg.role === 'user'
                    ? 'bg-blue-600 text-white rounded-br-none'
                    : 'bg-gray-800 text-gray-100 rounded-bl-none'
                }`}
              >
                <div className="whitespace-pre-wrap">{msg.content}</div>
                {msg.role === 'assistant' && (
                  <button
                    onClick={() => copyToClipboard(msg.content)}
                    className="text-xs text-gray-400 hover:text-gray-300 mt-1"
                  >
                    Copy
                  </button>
                )}
              </div>
            </div>
          ))
        )}
        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-gray-800 text-gray-100 rounded-2xl rounded-bl-none px-4 py-3">
              <div className="flex space-x-2">
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-75"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-150"></div>
              </div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={handleSubmit} className="mt-auto">
        <div className="flex gap-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Message Akin AI..."
            className="flex-1 bg-gray-800 border border-gray-700 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading}
          />
          <button
            type="submit"
            disabled={!input.trim() || isLoading}
            className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-700 text-white rounded-xl px-6 font-medium"
          >
            Send
          </button>
        </div>
      </form>

      <footer className="text-center text-xs text-gray-500 mt-8">
        Powered by Llama 3 via Groq • Akin AI v1.0
      </footer>
    </div>
  );
}
EOF

# Create API route
mkdir -p app/api/chat
cat > app/api/chat/route.ts <<'EOF'
import { NextRequest } from 'next/server';
import { Groq } from 'groq-sdk';

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export async function POST(req: NextRequest) {
  try {
    const { prompt } = await req.json();

    if (!prompt) {
      return new Response(JSON.stringify({ error: 'Prompt is required' }), { status: 400 });
    }

    const chatCompletion = await groq.chat.completions.create({
      messages: [{ role: 'user', content: prompt }],
      model: 'llama3-8b-8192',
      temperature: 0.7,
      max_tokens: 1024,
    });

    const reply = chatCompletion.choices[0]?.message?.content || 'No response';

    return new Response(JSON.stringify({ reply }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Groq API error:', error);
    return new Response(JSON.stringify({ error: 'Failed to generate response' }), { status: 500 });
  }
}
EOF

# Prompt for Groq API Key
echo ""
read -p "🔑 Enter your Groq API Key (get one at https://console.groq.com): "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"

# Create .env.local
cat > .env.local <<EOF
GROQ_API_KEY=$GROQ_KEY
EOF

# Install dependencies (suppress noise)
echo "📦 Installing dependencies..."
npm install --silent > /dev/null

echo ""
echo "✅ Akin AI is ready!"
echo ""
echo "▶️  Run these commands:"
echo "   cd akin-ai"
echo "   npm run dev"
echo ""
echo "🌐 Visit: http://localhost:3000"
echo "💡 Tip: Deploy to Vercel for free (1-click from GitHub)!"

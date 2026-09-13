import { useState, useEffect } from 'react';
import { X, Copy, Check, Download, Code2, FileCode, CheckCircle2 } from 'lucide-react';

interface CssExportModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function CssExportModal({ isOpen, onClose }: CssExportModalProps) {
  const [cssContent, setCssContent] = useState<string>('Carregando CSS...');
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (isOpen) {
      fetch('/biblivre.modern.css')
        .then((res) => res.text())
        .then((text) => setCssContent(text))
        .catch(() => setCssContent('/* Erro ao carregar o arquivo CSS */'));
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleCopy = () => {
    navigator.clipboard.writeText(cssContent);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownload = () => {
    const blob = new Blob([cssContent], { type: 'text/css' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'biblivre.modern.css';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const lineCount = cssContent.split('\n').length;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/70 backdrop-blur-xs">
      <div className="bg-slate-900 text-slate-100 border border-slate-700 rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] flex flex-col overflow-hidden">
        {/* Modal Header */}
        <div className="px-6 py-4 border-b border-slate-800 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-lg bg-blue-500/10 text-blue-400">
              <FileCode className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-white flex items-center gap-2">
                biblivre.modern.css
                <span className="text-xs px-2 py-0.5 rounded-full bg-blue-500/20 text-blue-300 font-normal">
                  {lineCount} linhas
                </span>
              </h2>
              <p className="text-xs text-slate-400">
                Camada de estilo moderna pronta para uso no seu servidor Biblivre 5 ou GitHub
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Integration Instructions */}
        <div className="px-6 py-3 bg-slate-800/40 border-b border-slate-800 text-xs text-slate-300 flex flex-wrap items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
            <span>
              <strong>Como usar no Biblivre:</strong> Substitua ou adicione este arquivo em{' '}
              <code className="bg-slate-800 px-1.5 py-0.5 rounded text-blue-300">
                webapps/biblivre5/static/styles/
              </code>
            </span>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handleCopy}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-md bg-blue-600 hover:bg-blue-500 text-white font-semibold transition-colors cursor-pointer"
            >
              {copied ? <Check className="w-3.5 h-3.5 text-emerald-300" /> : <Copy className="w-3.5 h-3.5" />}
              <span>{copied ? 'Copiado!' : 'Copiar CSS'}</span>
            </button>

            <button
              onClick={handleDownload}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-md bg-slate-700 hover:bg-slate-600 text-white font-semibold transition-colors cursor-pointer"
            >
              <Download className="w-3.5 h-3.5" />
              <span>Baixar Arquivo</span>
            </button>
          </div>
        </div>

        {/* Code Viewer */}
        <div className="flex-1 overflow-auto p-4 bg-slate-950 font-mono text-xs text-slate-300 leading-relaxed">
          <pre className="whitespace-pre">
            {cssContent}
          </pre>
        </div>
      </div>
    </div>
  );
}

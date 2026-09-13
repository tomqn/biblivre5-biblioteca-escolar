import { useState } from 'react';
import {
  Sparkles,
  Layers,
  Code2,
  Check,
  Copy,
  Download,
  GitBranch,
  Search,
  BookOpen,
  Repeat,
  CreditCard,
  Settings,
  SunMoon
} from 'lucide-react';
import { BiblivreScreen } from '../types';

interface TopSimulatorBarProps {
  isModernTheme: boolean;
  onToggleTheme: () => void;
  activeScreen: BiblivreScreen;
  onSelectScreen: (screen: BiblivreScreen) => void;
  onOpenCssModal: () => void;
}

export function TopSimulatorBar({
  isModernTheme,
  onToggleTheme,
  activeScreen,
  onSelectScreen,
  onOpenCssModal,
}: TopSimulatorBarProps) {
  const [copied, setCopied] = useState(false);

  const screens: { id: BiblivreScreen; label: string; icon: typeof Search }[] = [
    { id: 'search', label: 'Pesquisa (OPAC)', icon: Search },
    { id: 'cataloging', label: 'Catalogação & MARC', icon: BookOpen },
    { id: 'circulation', label: 'Circulação & Empréstimos', icon: Repeat },
    { id: 'reader_card', label: 'Carteirinha de Leitor', icon: CreditCard },
    { id: 'administration', label: 'Administração', icon: Settings },
  ];

  return (
    <header className="sticky top-0 z-50 bg-slate-900 text-slate-100 border-b border-slate-800 shadow-md">
      <div className="max-w-7xl mx-auto px-4 py-2.5 flex flex-wrap items-center justify-between gap-3">
        {/* Left: Project title & Git source indicator */}
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2">
            <span className="font-bold text-sm tracking-tight text-white flex items-center gap-1.5">
              <span className="w-2.5 h-2.5 rounded-full bg-blue-500 animate-pulse"></span>
              Biblivre 5
            </span>
            <span className="text-xs text-slate-400 font-medium">Biblioteca Escolar</span>
          </div>

          <div className="hidden sm:flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-slate-800 text-[11px] text-slate-300 font-mono border border-slate-700/60">
            <GitBranch className="w-3 h-3 text-emerald-400" />
            <span>tomqn/biblivre5-biblioteca-escolar</span>
          </div>
        </div>

        {/* Center: Screen selector */}
        <nav className="flex items-center gap-1 overflow-x-auto py-1 scrollbar-none">
          {screens.map((s) => {
            const Icon = s.icon;
            const isActive = activeScreen === s.id;
            return (
              <button
                key={s.id}
                onClick={() => onSelectScreen(s.id)}
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium transition-all cursor-pointer whitespace-nowrap ${
                  isActive
                    ? 'bg-blue-600 text-white shadow-sm font-semibold'
                    : 'text-slate-300 hover:text-white hover:bg-slate-800'
                }`}
              >
                <Icon className="w-3.5 h-3.5" />
                <span>{s.label}</span>
              </button>
            );
          })}
        </nav>

        {/* Right: Theme toggle & CSS Export button */}
        <div className="flex items-center gap-2">
          {/* Modern Theme vs Classic Biblivre 5 toggle */}
          <button
            onClick={onToggleTheme}
            id="btn-toggle-theme"
            title="Alternar entre o Tema Moderno e o visual clássico do Biblivre 5"
            className={`flex items-center gap-2 px-3 py-1.5 rounded-md text-xs font-semibold transition-all cursor-pointer border ${
              isModernTheme
                ? 'bg-emerald-500/20 text-emerald-300 border-emerald-500/50 hover:bg-emerald-500/30'
                : 'bg-amber-500/20 text-amber-300 border-amber-500/50 hover:bg-amber-500/30'
            }`}
          >
            <SunMoon className="w-3.5 h-3.5" />
            <span>{isModernTheme ? 'Tema Moderno: ATIVO' : 'Tema Clássico: ATIVO'}</span>
          </button>

          {/* Export / View biblivre.modern.css */}
          <button
            onClick={onOpenCssModal}
            id="btn-open-css-modal"
            className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-md text-xs font-medium bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 transition-colors cursor-pointer"
            title="Ver e copiar o arquivo biblivre.modern.css finalizado"
          >
            <Code2 className="w-3.5 h-3.5 text-blue-400" />
            <span className="hidden md:inline">Ver / Baixar CSS</span>
          </button>
        </div>
      </div>
    </header>
  );
}

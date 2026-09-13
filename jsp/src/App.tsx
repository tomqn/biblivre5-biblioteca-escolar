import { useState, useEffect } from 'react';
import { BiblivreScreen, BookRecord } from './types';
import { INITIAL_BOOKS } from './data/mockBiblivreData';
import { TopSimulatorBar } from './components/TopSimulatorBar';
import { BiblivreHeader } from './components/BiblivreHeader';
import { BiblivreSearchScreen } from './components/BiblivreSearchScreen';
import { BiblivreCatalogingScreen } from './components/BiblivreCatalogingScreen';
import { BiblivreCirculationScreen } from './components/BiblivreCirculationScreen';
import { BiblivreReaderCardScreen } from './components/BiblivreReaderCardScreen';
import { BiblivreAdminScreen } from './components/BiblivreAdminScreen';
import { CssExportModal } from './components/CssExportModal';

export default function App() {
  const [isModernTheme, setIsModernTheme] = useState<boolean>(true);
  const [activeScreen, setActiveScreen] = useState<BiblivreScreen>('search');
  const [books, setBooks] = useState<BookRecord[]>(INITIAL_BOOKS);
  const [libraryName, setLibraryName] = useState<string>('Biblioteca Escolar');
  const [isCssModalOpen, setIsCssModalOpen] = useState<boolean>(false);

  const [successMessage, setSuccessMessage] = useState<string | null>(
    'Tema moderno do Biblivre 5 ativo. Todos os módulos e estilos foram carregados com sucesso.'
  );
  const [warningMessage, setWarningMessage] = useState<string | null>(null);

  // Link stylesheet management
  useEffect(() => {
    // Ensure base stylesheets exist
    const ensureLink = (id: string, href: string) => {
      let link = document.getElementById(id) as HTMLLinkElement | null;
      if (!link) {
        link = document.createElement('link');
        link.id = id;
        link.rel = 'stylesheet';
        link.type = 'text/css';
        link.href = href;
        document.head.appendChild(link);
      }
      return link;
    };

    ensureLink('bb-core-css', '/biblivre.core.css');
    ensureLink('bb-search-css', '/biblivre.search.css');
    ensureLink('bb-cataloging-css', '/biblivre.cataloging.css');
    ensureLink('bb-circulation-css', '/biblivre.circulation.css');

    const modernLink = ensureLink('modern-theme', '/biblivre.modern.css');
    modernLink.disabled = !isModernTheme;
  }, [isModernTheme]);

  const handleShowMessage = (type: 'success' | 'warning', text: string) => {
    if (type === 'success') {
      setSuccessMessage(text);
      setWarningMessage(null);
    } else {
      setWarningMessage(text);
      setSuccessMessage(null);
    }
  };

  const handleToggleTheme = () => {
    const next = !isModernTheme;
    setIsModernTheme(next);
    handleShowMessage(
      'success',
      next
        ? 'Tema Moderno ativado: Layout fluido, design tokens, cartões responsivos e crachás de disponibilidade ativados.'
        : 'Tema Clássico ativado: Exibindo visual original legado do Biblivre 5.'
    );
  };

  return (
    <div className="min-h-screen flex flex-col bg-slate-100 selection:bg-blue-100 selection:text-blue-900">
      {/* Top simulator toolbar */}
      <TopSimulatorBar
        isModernTheme={isModernTheme}
        onToggleTheme={handleToggleTheme}
        activeScreen={activeScreen}
        onSelectScreen={setActiveScreen}
        onOpenCssModal={() => setIsCssModalOpen(true)}
      />

      {/* Biblivre Top Header & Submenus */}
      <BiblivreHeader
        libraryName={libraryName}
        activeScreen={activeScreen}
        onSelectScreen={setActiveScreen}
        successMessage={successMessage}
        warningMessage={warningMessage}
        onDismissMessage={() => {
          setSuccessMessage(null);
          setWarningMessage(null);
        }}
      />

      {/* Screen Views */}
      <main className="flex-1">
        {activeScreen === 'search' && (
          <BiblivreSearchScreen
            books={books}
            onOpenBookCataloging={() => setActiveScreen('cataloging')}
            onQuickLoan={() => setActiveScreen('circulation')}
            onShowMessage={handleShowMessage}
          />
        )}

        {activeScreen === 'cataloging' && (
          <BiblivreCatalogingScreen
            books={books}
            onShowMessage={handleShowMessage}
          />
        )}

        {activeScreen === 'circulation' && (
          <BiblivreCirculationScreen
            books={books}
            onShowMessage={handleShowMessage}
          />
        )}

        {activeScreen === 'reader_card' && (
          <BiblivreReaderCardScreen
            libraryName={libraryName}
            onShowMessage={handleShowMessage}
          />
        )}

        {activeScreen === 'administration' && (
          <BiblivreAdminScreen
            libraryName={libraryName}
            onUpdateLibraryName={setLibraryName}
            onShowMessage={handleShowMessage}
          />
        )}
      </main>

      {/* Floating Theme Toggle Quick Pill (Matching Devin's preview button) */}
      <button
        id="preview-toggle-floating"
        type="button"
        className="preview-toggle"
        onClick={handleToggleTheme}
        title="Clique para comparar o Tema Moderno vs Tema Clássico do Biblivre"
      >
        {isModernTheme ? 'Tema moderno: ON' : 'Tema moderno: OFF'}
      </button>

      {/* CSS Export Modal */}
      <CssExportModal
        isOpen={isCssModalOpen}
        onClose={() => setIsCssModalOpen(false)}
      />
    </div>
  );
}

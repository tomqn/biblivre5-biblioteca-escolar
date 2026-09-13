import { useState } from 'react';
import { BiblivreScreen } from '../types';

interface BiblivreHeaderProps {
  libraryName: string;
  activeScreen: BiblivreScreen;
  onSelectScreen: (screen: BiblivreScreen) => void;
  successMessage?: string | null;
  warningMessage?: string | null;
  onDismissMessage?: () => void;
}

export function BiblivreHeader({
  libraryName,
  activeScreen,
  onSelectScreen,
  successMessage,
  warningMessage,
  onDismissMessage,
}: BiblivreHeaderProps) {
  const [openSubmenu, setOpenSubmenu] = useState<string | null>(null);

  const getBreadcrumb = () => {
    switch (activeScreen) {
      case 'search':
        return (
          <>
            Pesquisa &raquo; <span>Bibliográfica (Catálogo Público)</span>
          </>
        );
      case 'cataloging':
        return (
          <>
            Catalogação &raquo; <span>Registro Bibliográfico & MARC 21</span>
          </>
        );
      case 'circulation':
        return (
          <>
            Circulação &raquo; <span>Empréstimo e Devolução</span>
          </>
        );
      case 'reader_card':
        return (
          <>
            Circulação &raquo; <span>Carteirinha de Leitor (Biblioteca Escolar)</span>
          </>
        );
      case 'administration':
        return (
          <>
            Administração &raquo; <span>Configurações & Permissões</span>
          </>
        );
      default:
        return (
          <>
            Início &raquo; <span>Biblioteca Escolar</span>
          </>
        );
    }
  };

  return (
    <div className="biblivre-wrapper">
      {/* Biblivre Top Header */}
      <div id="header" className="relative">
        <div id="title">
          <h1>
            <a href="#" onClick={(e) => { e.preventDefault(); onSelectScreen('search'); }}>
              {libraryName || 'Biblioteca Escolar'}
            </a>
          </h1>
          <h2>Catálogo público e Gestão · Biblivre 5</h2>
        </div>

        {/* Biblivre Menu Bar */}
        <div id="menu">
          <ul className="flex flex-wrap items-center">
            {/* Pesquisa */}
            <li
              className={`cursor-pointer relative ${activeScreen === 'search' ? 'font-bold' : ''}`}
              onClick={() => onSelectScreen('search')}
              onMouseEnter={() => setOpenSubmenu('search')}
              onMouseLeave={() => setOpenSubmenu(null)}
            >
              Pesquisa
              {openSubmenu === 'search' && (
                <div className="submenu absolute left-0 top-full shadow-lg z-50 flex flex-col py-1">
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('search');
                      setOpenSubmenu(null);
                    }}
                  >
                    Bibliográfica
                  </a>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('search');
                      setOpenSubmenu(null);
                    }}
                  >
                    Autoridades
                  </a>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('search');
                      setOpenSubmenu(null);
                    }}
                  >
                    Vocabulário
                  </a>
                </div>
              )}
            </li>

            {/* Circulação */}
            <li
              className={`cursor-pointer relative ${
                activeScreen === 'circulation' || activeScreen === 'reader_card' ? 'font-bold' : ''
              }`}
              onClick={() => onSelectScreen('circulation')}
              onMouseEnter={() => setOpenSubmenu('circulation')}
              onMouseLeave={() => setOpenSubmenu(null)}
            >
              Circulação
              {openSubmenu === 'circulation' && (
                <div className="submenu absolute left-0 top-full shadow-lg z-50 flex flex-col py-1">
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('circulation');
                      setOpenSubmenu(null);
                    }}
                  >
                    Empréstimo Rápido
                  </a>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('circulation');
                      setOpenSubmenu(null);
                    }}
                  >
                    Devoluções e Multas
                  </a>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('reader_card');
                      setOpenSubmenu(null);
                    }}
                  >
                    Carteirinha de Leitor
                  </a>
                </div>
              )}
            </li>

            {/* Catalogação */}
            <li
              className={`cursor-pointer relative ${activeScreen === 'cataloging' ? 'font-bold' : ''}`}
              onClick={() => onSelectScreen('cataloging')}
              onMouseEnter={() => setOpenSubmenu('cataloging')}
              onMouseLeave={() => setOpenSubmenu(null)}
            >
              Catalogação
              {openSubmenu === 'cataloging' && (
                <div className="submenu absolute left-0 top-full shadow-lg z-50 flex flex-col py-1">
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('cataloging');
                      setOpenSubmenu(null);
                    }}
                  >
                    Bibliográfica & MARC
                  </a>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('cataloging');
                      setOpenSubmenu(null);
                    }}
                  >
                    Exemplares
                  </a>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('cataloging');
                      setOpenSubmenu(null);
                    }}
                  >
                    Rótulos e Etiquetas
                  </a>
                </div>
              )}
            </li>

            {/* Aquisição */}
            <li
              className="cursor-pointer relative"
              onClick={() => onSelectScreen('administration')}
              onMouseEnter={() => setOpenSubmenu('acquisition')}
              onMouseLeave={() => setOpenSubmenu(null)}
            >
              Aquisição
              {openSubmenu === 'acquisition' && (
                <div className="submenu absolute left-0 top-full shadow-lg z-50 flex flex-col py-1">
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      setOpenSubmenu(null);
                    }}
                  >
                    Requisições e Pedidos
                  </a>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      setOpenSubmenu(null);
                    }}
                  >
                    Fornecedores
                  </a>
                </div>
              )}
            </li>

            {/* Administração */}
            <li
              className={`cursor-pointer relative ${activeScreen === 'administration' ? 'font-bold' : ''}`}
              onClick={() => onSelectScreen('administration')}
              onMouseEnter={() => setOpenSubmenu('admin')}
              onMouseLeave={() => setOpenSubmenu(null)}
            >
              Administração
              {openSubmenu === 'admin' && (
                <div className="submenu absolute left-0 top-full shadow-lg z-50 flex flex-col py-1">
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('administration');
                      setOpenSubmenu(null);
                    }}
                  >
                    Permissões e Usuários
                  </a>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('administration');
                      setOpenSubmenu(null);
                    }}
                  >
                    Configurações do Sistema
                  </a>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      onSelectScreen('administration');
                      setOpenSubmenu(null);
                    }}
                  >
                    Backup e Restauração
                  </a>
                </div>
              )}
            </li>

            {/* Carteirinha Rápida */}
            <li
              className={`cursor-pointer hidden sm:block ${activeScreen === 'reader_card' ? 'font-bold' : ''}`}
              onClick={() => onSelectScreen('reader_card')}
            >
              Carteirinha
            </li>

            {/* Logout / User chip */}
            <li className="logout ml-auto cursor-pointer" onClick={() => onSelectScreen('search')}>
              Bibliotecário · Sair
            </li>
          </ul>
        </div>
      </div>

      {/* Notifications and Breadcrumbs */}
      <div id="notifications">
        <div id="breadcrumb">{getBreadcrumb()}</div>
      </div>

      {/* Messages */}
      <div id="messages">
        {successMessage && (
          <div className="message success relative group">
            <div className="flex justify-between items-center">
              <span>{successMessage}</span>
              {onDismissMessage && (
                <button
                  type="button"
                  onClick={onDismissMessage}
                  className="text-xs opacity-70 hover:opacity-100 cursor-pointer ml-4 font-bold"
                >
                  &times; Fechar
                </button>
              )}
            </div>
          </div>
        )}
        {warningMessage && (
          <div className="message warning relative group">
            <div className="flex justify-between items-center">
              <span>{warningMessage}</span>
              {onDismissMessage && (
                <button
                  type="button"
                  onClick={onDismissMessage}
                  className="text-xs opacity-70 hover:opacity-100 cursor-pointer ml-4 font-bold"
                >
                  &times; Fechar
                </button>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

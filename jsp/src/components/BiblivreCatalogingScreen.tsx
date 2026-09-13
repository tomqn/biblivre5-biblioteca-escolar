import { useState } from 'react';
import { BookRecord, MarcField } from '../types';
import { SAMPLE_MARC_RECORD, SAMPLE_HOLDINGS } from '../data/mockBiblivreData';
import { Plus, Trash2, Save, FileText, CheckCircle2 } from 'lucide-react';

interface BiblivreCatalogingScreenProps {
  books: BookRecord[];
  onShowMessage: (type: 'success' | 'warning', text: string) => void;
}

export function BiblivreCatalogingScreen({
  books,
  onShowMessage,
}: BiblivreCatalogingScreenProps) {
  const [selectedBook, setSelectedBook] = useState<BookRecord>(books[0]);
  const [activeCatalogTab, setActiveCatalogTab] = useState<'form' | 'marc' | 'holdings'>('form');

  // Form states
  const [title, setTitle] = useState(selectedBook.title);
  const [author, setAuthor] = useState(selectedBook.author);
  const [publisher, setPublisher] = useState(selectedBook.publisher);
  const [year, setYear] = useState(selectedBook.year);
  const [shelf, setShelf] = useState(selectedBook.shelfLocation);
  const [isbn, setIsbn] = useState(selectedBook.isbn);
  const [subject, setSubject] = useState(selectedBook.subject);

  const handleSelectBook = (book: BookRecord) => {
    setSelectedBook(book);
    setTitle(book.title);
    setAuthor(book.author);
    setPublisher(book.publisher);
    setYear(book.year);
    setShelf(book.shelfLocation);
    setIsbn(book.isbn);
    setSubject(book.subject);
  };

  const handleSaveRecord = () => {
    onShowMessage('success', `Registro catalográfico "${title}" atualizado com sucesso no banco de dados!`);
  };

  return (
    <div id="content_outer">
      <div id="content">
        <div id="content_inner">
          <div className="page_help">
            Módulo de Catalogação: Cadastre novos materiais, edite campos MARC 21 (tags 100, 245, 260, 650) e faça o gerenciamento físico dos exemplares do acervo.
          </div>

          <div className="page_title">
            <div className="text contains_subtext">
              Catalogação Bibliográfica (MARC 21)
              <div className="subtext">Controle de títulos, autoridades e exemplares físicos</div>
            </div>
            <div className="clear"></div>
          </div>

          {/* Quick Book Selector */}
          <div className="flex flex-wrap items-center gap-2 my-3 p-3 bg-slate-50 border border-slate-200 rounded-lg">
            <span className="text-xs font-semibold text-slate-600">Selecionar registro:</span>
            {books.map((b) => (
              <button
                key={b.id}
                onClick={() => handleSelectBook(b)}
                className={`px-2.5 py-1 text-xs rounded border transition-colors cursor-pointer ${
                  selectedBook.id === b.id
                    ? 'bg-blue-600 text-white border-blue-600 font-semibold'
                    : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-100'
                }`}
              >
                {b.title}
              </button>
            ))}
          </div>

          {/* Cataloging Tabs */}
          <div className="selected_record tabs mt-4" style={{ display: 'block' }}>
            <ul className="tabs_head">
              <li
                className={`tab cursor-pointer ${activeCatalogTab === 'form' ? 'tab_selected' : ''}`}
                onClick={() => setActiveCatalogTab('form')}
              >
                Formulário Simplificado
              </li>
              <li
                className={`tab cursor-pointer ${activeCatalogTab === 'marc' ? 'tab_selected' : ''}`}
                onClick={() => setActiveCatalogTab('marc')}
              >
                Campos MARC 21
              </li>
              <li
                className={`tab cursor-pointer ${activeCatalogTab === 'holdings' ? 'tab_selected' : ''}`}
                onClick={() => setActiveCatalogTab('holdings')}
              >
                Exemplares ({selectedBook.totalCopies})
              </li>
            </ul>

            <div className="tabs_body">
              {/* FORM TAB */}
              {activeCatalogTab === 'form' && (
                <div className="tab_body tab_selected space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-semibold mb-1 text-slate-700">
                        Título Principal (Campo MARC 245 $a)
                      </label>
                      <input
                        type="text"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        className="big_input w-full"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold mb-1 text-slate-700">
                        Autor / Responsabilidade (Campo MARC 100 $a)
                      </label>
                      <input
                        type="text"
                        value={author}
                        onChange={(e) => setAuthor(e.target.value)}
                        className="big_input w-full"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold mb-1 text-slate-700">
                        Editora e Local (Campo MARC 260 $a $b)
                      </label>
                      <input
                        type="text"
                        value={publisher}
                        onChange={(e) => setPublisher(e.target.value)}
                        className="w-full"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold mb-1 text-slate-700">
                        Ano de Publicação (Campo MARC 260 $c)
                      </label>
                      <input
                        type="number"
                        value={year}
                        onChange={(e) => setYear(Number(e.target.value))}
                        className="w-full"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold mb-1 text-slate-700">
                        Localização na Estante / Classificação (Campo MARC 090 $a)
                      </label>
                      <input
                        type="text"
                        value={shelf}
                        onChange={(e) => setShelf(e.target.value)}
                        className="w-full font-mono"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold mb-1 text-slate-700">
                        ISBN (Campo MARC 020 $a)
                      </label>
                      <input
                        type="text"
                        value={isbn}
                        onChange={(e) => setIsbn(e.target.value)}
                        className="w-full font-mono"
                      />
                    </div>

                    <div className="md:col-span-2">
                      <label className="block text-xs font-semibold mb-1 text-slate-700">
                        Assuntos / Palavras-chave (Campo MARC 650 $a)
                      </label>
                      <input
                        type="text"
                        value={subject}
                        onChange={(e) => setSubject(e.target.value)}
                        className="w-full"
                      />
                    </div>
                  </div>

                  <div className="footer_buttons pt-3 border-t border-slate-200">
                    <a className="main_button cursor-pointer" onClick={handleSaveRecord}>
                      Salvar Alterações
                    </a>
                    <a
                      className="button cursor-pointer"
                      onClick={() => onShowMessage('success', 'Ficha catalográfica ABNT gerada em PDF.')}
                    >
                      Gerar Ficha Catalográfica
                    </a>
                    <a
                      className="button cursor-pointer"
                      onClick={() => onShowMessage('success', 'Rótulos e etiquetas de lombada enviadas para a fila de impressão.')}
                    >
                      Imprimir Etiquetas de Lombada
                    </a>
                  </div>
                </div>
              )}

              {/* MARC 21 TAB */}
              {activeCatalogTab === 'marc' && (
                <div className="tab_body tab_selected">
                  <div className="mb-3 text-xs text-slate-500">
                    Formato bibliográfico internacional MARC 21 completo para intercâmbio de dados (Protocolo Z39.50).
                  </div>

                  <div className="marc_viewer">
                    {SAMPLE_MARC_RECORD.map((f, i) => (
                      <div key={i} className="marc_field">
                        <span className="marc_tag">{f.tag}</span>
                        <span className="marc_ind">{f.ind1 || '#'}{f.ind2 || '#'}</span>
                        <span className="marc_data">
                          {f.subfields.map((sf, sfi) => (
                            <span key={sfi} className="marc_subfield">
                              <span className="marc_subfield_code">${sf.code}</span>
                              <span>{sf.value} </span>
                            </span>
                          ))}
                        </span>
                      </div>
                    ))}
                  </div>

                  <div className="footer_buttons mt-4">
                    <a
                      className="button cursor-pointer"
                      onClick={() => onShowMessage('success', 'Registro MARC 21 validado sem erros de sintaxe.')}
                    >
                      Validar Registro
                    </a>
                    <a
                      className="button cursor-pointer"
                      onClick={() => onShowMessage('success', 'Arquivo .mrc exportado.')}
                    >
                      Exportar ISO 2709
                    </a>
                  </div>
                </div>
              )}

              {/* HOLDINGS TAB */}
              {activeCatalogTab === 'holdings' && (
                <div className="tab_body tab_selected">
                  <div className="flex justify-between items-center mb-3">
                    <span className="text-xs text-slate-500">
                      Exemplares físicos vinculados a esta obra
                    </span>
                    <a
                      className="main_button cursor-pointer text-xs"
                      onClick={() => onShowMessage('success', 'Novo exemplar cadastrado com código sequencial.')}
                    >
                      + Novo Exemplar
                    </a>
                  </div>

                  <table className="holdings_table">
                    <thead>
                      <tr>
                        <th>Tombo Patrimonial</th>
                        <th>Cód. Barras</th>
                        <th>Volume</th>
                        <th>Localização / Estante</th>
                        <th>Data Registro</th>
                        <th>Situação</th>
                      </tr>
                    </thead>
                    <tbody>
                      {SAMPLE_HOLDINGS.map((h) => (
                        <tr key={h.id}>
                          <td className="font-mono font-semibold">{h.id}</td>
                          <td className="font-mono">{h.barcode}</td>
                          <td>{h.volume}</td>
                          <td>{h.shelf}</td>
                          <td>{h.acquisitionDate}</td>
                          <td>
                            <span className={`status_pill ${h.status}`}>
                              {h.status === 'available' && 'Disponível'}
                              {h.status === 'borrowed' && 'Emprestado'}
                              {h.status === 'reserved' && 'Reservado'}
                              {h.status === 'overdue' && 'Atrasado'}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>
        </div>
        <div id="copyright">Biblivre 5 — Software Livre para Gestão de Bibliotecas Escolares</div>
      </div>
    </div>
  );
}

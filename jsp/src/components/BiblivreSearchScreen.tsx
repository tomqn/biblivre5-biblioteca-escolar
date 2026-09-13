import { useState } from 'react';
import { BookRecord } from '../types';
import { SAMPLE_MARC_RECORD, SAMPLE_HOLDINGS } from '../data/mockBiblivreData';
import { Book, Bookmark, CheckCircle2, AlertCircle, Share2, Printer } from 'lucide-react';

interface BiblivreSearchScreenProps {
  books: BookRecord[];
  onOpenBookCataloging: (book: BookRecord) => void;
  onQuickLoan: (book: BookRecord) => void;
  onShowMessage: (type: 'success' | 'warning', text: string) => void;
}

export function BiblivreSearchScreen({
  books,
  onOpenBookCataloging,
  onQuickLoan,
  onShowMessage,
}: BiblivreSearchScreenProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [materialFilter, setMaterialFilter] = useState('Todos');
  const [isAdvanced, setIsAdvanced] = useState(false);
  const [advOperator, setAdvOperator] = useState('AND');
  const [advField, setAdvField] = useState('title');
  const [advQuery, setAdvQuery] = useState('');
  const [selectedFacet, setSelectedFacet] = useState<'all' | 'title' | 'author' | 'subject'>('all');
  const [selectedBook, setSelectedBook] = useState<BookRecord | null>(books[0] || null);
  const [activeTab, setActiveTab] = useState<'summary' | 'form' | 'marc' | 'holdings'>('summary');
  const [sortBy, setSortBy] = useState<'title' | 'year'>('title');

  // Filter books
  const filteredBooks = books.filter((b) => {
    const q = searchQuery.toLowerCase().trim();
    if (materialFilter !== 'Todos' && b.materialType !== materialFilter) return false;

    if (q) {
      const matchesTitle = b.title.toLowerCase().includes(q);
      const matchesAuthor = b.author.toLowerCase().includes(q);
      const matchesSubject = b.subject.toLowerCase().includes(q);
      const matchesIsbn = b.isbn.toLowerCase().includes(q);
      const matchesShelf = b.shelfLocation.toLowerCase().includes(q);

      if (selectedFacet === 'title' && !matchesTitle) return false;
      if (selectedFacet === 'author' && !matchesAuthor) return false;
      if (selectedFacet === 'subject' && !matchesSubject) return false;

      if (selectedFacet === 'all') {
        if (!matchesTitle && !matchesAuthor && !matchesSubject && !matchesIsbn && !matchesShelf) {
          return false;
        }
      }
    }

    if (isAdvanced && advQuery.trim()) {
      const aq = advQuery.toLowerCase().trim();
      let match = false;
      if (advField === 'title') match = b.title.toLowerCase().includes(aq);
      else if (advField === 'author') match = b.author.toLowerCase().includes(aq);
      else if (advField === 'subject') match = b.subject.toLowerCase().includes(aq);
      else if (advField === 'isbn') match = b.isbn.toLowerCase().includes(aq);
      else match = b.title.toLowerCase().includes(aq) || b.author.toLowerCase().includes(aq);

      if (advOperator === 'NOT') {
        if (match) return false;
      } else if (advOperator === 'AND') {
        if (!match) return false;
      }
    }

    return true;
  }).sort((a, b) => {
    if (sortBy === 'title') return a.title.localeCompare(b.title);
    return b.year - a.year;
  });

  return (
    <div id="content_outer">
      <div id="content">
        <div id="content_inner">
          {/* Page Help */}
          <div className="page_help">
            Pesquise por título, autor, assunto, ISBN ou localização na estante. Use a busca avançada para combinar campos com os operadores E / OU / E NÃO.
          </div>

          <div id="cataloging_search">
            {/* Page Title */}
            <div className="page_title">
              <div className="text contains_subtext">
                Pesquisa bibliográfica
                <div className="subtext">
                  Alternar para{' '}
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      setIsAdvanced(!isAdvanced);
                    }}
                  >
                    {isAdvanced ? 'pesquisa simples' : 'pesquisa avançada'}
                  </a>
                </div>
              </div>
              <div className="clear"></div>
            </div>

            {/* Search Box */}
            <div className="search_box">
              {!isAdvanced ? (
                <div className="simple_search flex flex-wrap items-end gap-3">
                  <div className="query flex-1 min-w-[260px]">
                    <input
                      type="text"
                      name="query"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="big_input w-full"
                      placeholder="Título, autor, assunto, ISBN, estante..."
                      id="search-input-simple"
                    />
                  </div>
                  <div className="buttons flex items-end gap-2">
                    <div>
                      <label className="search_label block text-xs font-semibold mb-1" htmlFor="material">
                        Tipo de material
                      </label>
                      <select
                        id="material"
                        name="material"
                        value={materialFilter}
                        onChange={(e) => setMaterialFilter(e.target.value)}
                      >
                        <option value="Todos">Todos os materiais</option>
                        <option value="Livro">Livro</option>
                        <option value="Periódico">Periódico / Revista</option>
                        <option value="Material Especial">Material Especial</option>
                      </select>
                    </div>
                    <a
                      className="main_button cursor-pointer"
                      onClick={() => onShowMessage('success', `Busca atualizada: ${filteredBooks.length} registros encontrados.`)}
                    >
                      Pesquisar
                    </a>
                  </div>
                </div>
              ) : (
                /* Advanced Search */
                <div className="advanced_search space-y-3">
                  <div className="search_entry flex flex-wrap gap-2 items-end">
                    <div className="query flex-1 min-w-[200px]">
                      <label className="search_label block text-xs font-semibold mb-1">Termo principal</label>
                      <input
                        type="text"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="big_input w-full"
                        placeholder="Primeiro termo..."
                      />
                    </div>
                    <div className="field w-44">
                      <label className="search_label block text-xs font-semibold mb-1">Campo</label>
                      <select className="w-full">
                        <option>Todos os campos</option>
                        <option>Título</option>
                        <option>Autor</option>
                        <option>Assunto</option>
                      </select>
                    </div>
                  </div>

                  <div className="search_entry flex flex-wrap gap-2 items-end">
                    <div className="operator w-28">
                      <label className="search_label block text-xs font-semibold mb-1">Operador</label>
                      <select
                        value={advOperator}
                        onChange={(e) => setAdvOperator(e.target.value)}
                        className="w-full"
                      >
                        <option value="AND">E (AND)</option>
                        <option value="OR">OU (OR)</option>
                        <option value="NOT">E NÃO (NOT)</option>
                      </select>
                    </div>
                    <div className="query flex-1 min-w-[200px]">
                      <label className="search_label block text-xs font-semibold mb-1">Termo secundário</label>
                      <input
                        type="text"
                        value={advQuery}
                        onChange={(e) => setAdvQuery(e.target.value)}
                        className="big_input w-full"
                        placeholder="Segundo termo de busca..."
                      />
                    </div>
                    <div className="field w-44">
                      <label className="search_label block text-xs font-semibold mb-1">Campo</label>
                      <select
                        value={advField}
                        onChange={(e) => setAdvField(e.target.value)}
                        className="w-full"
                      >
                        <option value="title">Título</option>
                        <option value="author">Autor</option>
                        <option value="subject">Assunto</option>
                        <option value="isbn">ISBN</option>
                      </select>
                    </div>
                    <a
                      className="main_button cursor-pointer"
                      onClick={() => onShowMessage('success', `Busca avançada: ${filteredBooks.length} registros encontrados.`)}
                    >
                      Pesquisar
                    </a>
                  </div>
                </div>
              )}
            </div>

            {/* Ordering and Facet Bar */}
            <div className="search_results_area">
              <div className="search_ordering_bar flex justify-between items-center flex-wrap gap-3">
                <div className="search_indexing_groups flex flex-wrap gap-1">
                  <div
                    className={`cursor-pointer ${selectedFacet === 'all' ? 'selected' : ''}`}
                    onClick={() => setSelectedFacet('all')}
                  >
                    <span className="name">Todos</span> <span className="value">({books.length})</span>
                  </div>
                  <div
                    className={`cursor-pointer ${selectedFacet === 'title' ? 'selected' : ''}`}
                    onClick={() => setSelectedFacet('title')}
                  >
                    <a href="#" onClick={(e) => e.preventDefault()}>Título</a> <span className="value">({books.length})</span>
                  </div>
                  <div
                    className={`cursor-pointer ${selectedFacet === 'author' ? 'selected' : ''}`}
                    onClick={() => setSelectedFacet('author')}
                  >
                    <a href="#" onClick={(e) => e.preventDefault()}>Autor</a> <span className="value">({books.length})</span>
                  </div>
                  <div
                    className={`cursor-pointer ${selectedFacet === 'subject' ? 'selected' : ''}`}
                    onClick={() => setSelectedFacet('subject')}
                  >
                    <a href="#" onClick={(e) => e.preventDefault()}>Assunto</a> <span className="value">({books.length})</span>
                  </div>
                </div>

                <div className="search_sort_by flex items-center gap-2 text-xs">
                  <span>Ordenar por:</span>
                  <select
                    value={sortBy}
                    onChange={(e) => setSortBy(e.target.value as 'title' | 'year')}
                    className="text-xs py-1"
                  >
                    <option value="title">Título (A-Z)</option>
                    <option value="year">Ano de publicação</option>
                  </select>
                </div>
              </div>

              {/* Select Page Bar */}
              <div className="select_bar flex justify-between items-center mb-2">
                <a
                  className="button center cursor-pointer text-xs"
                  onClick={() => onShowMessage('success', 'Todos os 6 registros da página foram selecionados.')}
                >
                  Selecionar página
                </a>
                <span className="text-xs text-slate-500">
                  Mostrando 1 a {filteredBooks.length} de {filteredBooks.length} registros
                </span>
              </div>

              {/* Paging Bar Top */}
              <div className="paging_bar">
                <a className="paging_button paging_button_prev cursor-pointer">Anterior</a>
                <span className="paging actual_page">1</span>
                <a className="paging cursor-pointer">2</a>
                <a className="paging cursor-pointer">3</a>
                <a className="paging_button paging_button_next cursor-pointer">Próxima</a>
              </div>

              {/* Results List */}
              <div className="search_results_box">
                {filteredBooks.length === 0 ? (
                  <div className="no_results">
                    Nenhum registro bibliográfico encontrado para os termos pesquisados.
                  </div>
                ) : (
                  <div className="search_results">
                    {filteredBooks.map((book, idx) => {
                      const isSelected = selectedBook?.id === book.id;
                      const isEven = idx % 2 === 1;

                      return (
                        <div
                          key={book.id}
                          className={`result ${isEven ? 'even' : 'odd'} ${isSelected ? 'selected' : ''}`}
                        >
                          {/* Action buttons on the side */}
                          <div className="buttons">
                            <a
                              className="button center cursor-pointer"
                              onClick={() => {
                                setSelectedBook(book);
                                onShowMessage('success', `Registro "${book.title}" selecionado para exibição.`);
                              }}
                            >
                              Abrir
                            </a>
                            <a
                              className="button center cursor-pointer"
                              onClick={() => onOpenBookCataloging(book)}
                            >
                              Catalogar
                            </a>
                            <a
                              className="button center cursor-pointer"
                              onClick={() => onQuickLoan(book)}
                            >
                              Emprestar
                            </a>
                          </div>

                          {/* Record bibliographic content */}
                          <div className="record">
                            <label>Título</label>: <strong>{book.title}</strong>
                            <br />
                            <label>Autor</label>:{' '}
                            <a
                              href="#"
                              onClick={(e) => {
                                e.preventDefault();
                                setSearchQuery(book.author);
                              }}
                            >
                              {book.author}
                            </a>
                            <br />
                            <label>Ano de publicação</label>: {book.year}
                            <br />
                            <label>Localização na estante</label>:{' '}
                            <span className="font-mono font-semibold text-blue-700 bg-blue-50 px-1.5 py-0.5 rounded border border-blue-200">
                              {book.shelfLocation}
                            </span>
                            <br />
                            <label>ISBN</label>: {book.isbn}
                            <br />
                            <label>Assunto</label>:{' '}
                            <a
                              href="#"
                              onClick={(e) => {
                                e.preventDefault();
                                setSearchQuery(book.subject);
                              }}
                            >
                              {book.subject}
                            </a>
                            <div className="ncspacer"></div>

                            {/* Copies availability badge */}
                            <label>Exemplares</label>: {book.totalCopies} -{' '}
                            <small>
                              <label>disponíveis: {book.availableCopies}</label>&#160;
                              <label>emprestados: {book.borrowedCopies}</label>&#160;
                              <label>reservados: {book.reservedCopies}</label>
                            </small>
                          </div>
                          <div className="clear"></div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>

              {/* Paging Bar Bottom */}
              <div className="paging_bar">
                <span className="paging actual_page">1</span>
                <a className="paging cursor-pointer">2</a>
                <a className="paging cursor-pointer">3</a>
              </div>
            </div>

            {/* Selected Record Tabs (Full Detail) */}
            {selectedBook && (
              <div className="selected_record tabs mt-6" style={{ display: 'block' }}>
                <ul className="tabs_head">
                  <li
                    className={`tab cursor-pointer ${activeTab === 'summary' ? 'tab_selected' : ''}`}
                    onClick={() => setActiveTab('summary')}
                  >
                    Resumo
                  </li>
                  <li
                    className={`tab cursor-pointer ${activeTab === 'form' ? 'tab_selected' : ''}`}
                    onClick={() => setActiveTab('form')}
                  >
                    Formulário
                  </li>
                  <li
                    className={`tab cursor-pointer ${activeTab === 'marc' ? 'tab_selected' : ''}`}
                    onClick={() => setActiveTab('marc')}
                  >
                    MARC 21
                  </li>
                  <li
                    className={`tab cursor-pointer ${activeTab === 'holdings' ? 'tab_selected' : ''}`}
                    onClick={() => setActiveTab('holdings')}
                  >
                    Exemplares ({selectedBook.totalCopies})
                  </li>
                </ul>

                <div className="tabs_body">
                  {/* TAB 1: RESUMO */}
                  {activeTab === 'summary' && (
                    <div className="tab_body tab_selected">
                      <table className="record_fields">
                        <tbody>
                          <tr>
                            <td className="label">Tipo de material:</td>
                            <td className="value">{selectedBook.materialType}</td>
                          </tr>
                          <tr>
                            <td className="label">Título principal:</td>
                            <td className="value font-semibold">{selectedBook.title}</td>
                          </tr>
                          <tr>
                            <td className="label">Autor:</td>
                            <td className="value">{selectedBook.author}</td>
                          </tr>
                          <tr>
                            <td className="label">Editora e ano:</td>
                            <td className="value">{selectedBook.publisher}, {selectedBook.year}</td>
                          </tr>
                          <tr>
                            <td className="label">Classificação / Estante:</td>
                            <td className="value">
                              <span className="font-mono font-bold text-blue-700 bg-blue-50 px-2 py-0.5 rounded border border-blue-200">
                                {selectedBook.shelfLocation}
                              </span>
                            </td>
                          </tr>
                          <tr>
                            <td className="label">ISBN:</td>
                            <td className="value font-mono">{selectedBook.isbn}</td>
                          </tr>
                          <tr>
                            <td className="label">Assuntos:</td>
                            <td className="value">{selectedBook.subject}</td>
                          </tr>
                          <tr>
                            <td className="label">Resumo / Sinopse:</td>
                            <td className="value text-slate-600 leading-relaxed">{selectedBook.summary}</td>
                          </tr>
                        </tbody>
                      </table>

                      <div className="footer_buttons mt-5">
                        <a
                          className="main_button cursor-pointer"
                          onClick={() => onShowMessage('success', `Registro "${selectedBook.title}" salvo com sucesso.`)}
                        >
                          Salvar
                        </a>
                        <a
                          className="button cursor-pointer"
                          onClick={() => onShowMessage('success', 'Registro exportado em formato MARC21 / ISO 2709.')}
                        >
                          Exportar
                        </a>
                        <a
                          className="faded_button cursor-pointer"
                          onClick={() => onShowMessage('success', 'Novo registro criado a partir do modelo atual.')}
                        >
                          Duplicar
                        </a>
                        <a
                          className="danger_button cursor-pointer"
                          onClick={() => onShowMessage('warning', 'Tem certeza que deseja excluir este registro?')}
                        >
                          Excluir
                        </a>
                      </div>
                    </div>
                  )}

                  {/* TAB 2: FORMULÁRIO */}
                  {activeTab === 'form' && (
                    <div className="tab_body tab_selected space-y-3">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                          <label className="block text-xs font-semibold mb-1">Título principal (245 $a)</label>
                          <input type="text" className="w-full" defaultValue={selectedBook.title} />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold mb-1">Autor pessoal (100 $a)</label>
                          <input type="text" className="w-full" defaultValue={selectedBook.author} />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold mb-1">Editora (260 $b)</label>
                          <input type="text" className="w-full" defaultValue={selectedBook.publisher} />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold mb-1">Ano de publicação (260 $c)</label>
                          <input type="number" className="w-full" defaultValue={selectedBook.year} />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold mb-1">Localização na estante (090 $a)</label>
                          <input type="text" className="w-full" defaultValue={selectedBook.shelfLocation} />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold mb-1">ISBN (020 $a)</label>
                          <input type="text" className="w-full" defaultValue={selectedBook.isbn} />
                        </div>
                      </div>

                      <div className="footer_buttons mt-4">
                        <a
                          className="main_button cursor-pointer"
                          onClick={() => onShowMessage('success', 'Alterações do formulário salvas.')}
                        >
                          Atualizar Cadastro
                        </a>
                      </div>
                    </div>
                  )}

                  {/* TAB 3: MARC 21 */}
                  {activeTab === 'marc' && (
                    <div className="tab_body tab_selected">
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
                    </div>
                  )}

                  {/* TAB 4: EXEMPLARES */}
                  {activeTab === 'holdings' && (
                    <div className="tab_body tab_selected">
                      <table className="holdings_table">
                        <thead>
                          <tr>
                            <th>Tombo / ID</th>
                            <th>Cód. Barras</th>
                            <th>Volume</th>
                            <th>Localização</th>
                            <th>Data Entrada</th>
                            <th>Situação</th>
                            <th>Ações</th>
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
                              <td>
                                {h.status === 'available' ? (
                                  <a
                                    className="button cursor-pointer text-xs"
                                    onClick={() => onQuickLoan(selectedBook)}
                                  >
                                    Emprestar
                                  </a>
                                ) : (
                                  <span className="text-xs text-slate-400">
                                    {h.borrowerName?.split(' ')[0]}
                                  </span>
                                )}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
        <div id="copyright">Biblivre 5 — Software Livre para Gestão de Bibliotecas Escolares</div>
      </div>
    </div>
  );
}

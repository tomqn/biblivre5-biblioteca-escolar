import { useState } from 'react';
import { Reader, ActiveLoan, BookRecord } from '../types';
import { SAMPLE_READERS, INITIAL_ACTIVE_LOANS } from '../data/mockBiblivreData';
import { UserCheck, BookPlus, AlertTriangle, RotateCcw, Check, Clock } from 'lucide-react';

interface BiblivreCirculationScreenProps {
  books: BookRecord[];
  onShowMessage: (type: 'success' | 'warning', text: string) => void;
}

export function BiblivreCirculationScreen({
  books,
  onShowMessage,
}: BiblivreCirculationScreenProps) {
  const [readers] = useState<Reader[]>(SAMPLE_READERS);
  const [activeLoans, setActiveLoans] = useState<ActiveLoan[]>(INITIAL_ACTIVE_LOANS);

  // Form states
  const [selectedReaderId, setSelectedReaderId] = useState<string>(readers[0].id);
  const [selectedBookBarcode, setSelectedBookBarcode] = useState<string>('202600124');
  const [loanDays, setLoanDays] = useState<number>(14);

  const selectedReader = readers.find((r) => r.id === selectedReaderId) || readers[0];

  const handleCreateLoan = () => {
    const book = books.find((b) => b.availableCopies > 0) || books[0];
    const newLoan: ActiveLoan = {
      id: `LOAN-${Math.floor(1000 + Math.random() * 9000)}`,
      bookTitle: book.title,
      barcode: selectedBookBarcode || '202600999',
      readerName: selectedReader.name,
      readerEnrollment: selectedReader.enrollmentId,
      loanDate: new Date().toLocaleDateString('pt-BR'),
      dueDate: new Date(Date.now() + loanDays * 86400000).toLocaleDateString('pt-BR'),
      isOverdue: false,
    };

    setActiveLoans([newLoan, ...activeLoans]);
    onShowMessage(
      'success',
      `Empréstimo registrado com sucesso para ${selectedReader.name}! Devolução até ${newLoan.dueDate}.`
    );
  };

  const handleReturnBook = (loanId: string) => {
    const loan = activeLoans.find((l) => l.id === loanId);
    setActiveLoans(activeLoans.filter((l) => l.id !== loanId));
    if (loan?.isOverdue) {
      onShowMessage(
        'warning',
        `Devolução de "${loan.bookTitle}" concluída com 2 dias de atraso. Multa simbólica calculada: R$ 2,00.`
      );
    } else {
      onShowMessage('success', `Exemplar "${loan?.bookTitle}" devolvido ao acervo escolar.`);
    }
  };

  const handleRenewLoan = (loanId: string) => {
    setActiveLoans(
      activeLoans.map((l) => {
        if (l.id === loanId) {
          return {
            ...l,
            dueDate: new Date(Date.now() + 14 * 86400000).toLocaleDateString('pt-BR'),
            isOverdue: false,
          };
        }
        return l;
      })
    );
    onShowMessage('success', 'Prazo de empréstimo renovado por mais 14 dias.');
  };

  return (
    <div id="content_outer">
      <div id="content">
        <div id="content_inner">
          <div className="page_help">
            Módulo de Circulação: Realize empréstimos rápidos, devoluções, controle de atrasos e renovação de prazos para alunos e professores da escola.
          </div>

          <div className="page_title">
            <div className="text contains_subtext">
              Circulação de Acervo Escolar
              <div className="subtext">Empréstimos, devoluções e situação dos leitores</div>
            </div>
            <div className="clear"></div>
          </div>

          {/* Quick Loan Block */}
          <fieldset className="block mt-4 mb-6">
            <legend className="text-sm font-bold text-slate-800">Empréstimo Rápido (Circulação)</legend>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-2">
              {/* Leitor */}
              <div>
                <label className="block text-xs font-semibold mb-1 text-slate-700" htmlFor="leitor-select">
                  Identificação do Leitor (Aluno / Professor)
                </label>
                <select
                  id="leitor-select"
                  value={selectedReaderId}
                  onChange={(e) => setSelectedReaderId(e.target.value)}
                  className="w-full"
                >
                  {readers.map((r) => (
                    <option key={r.id} value={r.id}>
                      {r.name} — {r.turma || r.category} (Matrícula: {r.enrollmentId})
                    </option>
                  ))}
                </select>

                {/* Reader Card preview chip */}
                {selectedReader && (
                  <div className="mt-2 p-2.5 bg-blue-50 border border-blue-200 rounded-md text-xs text-slate-700">
                    <div className="font-semibold text-blue-900">{selectedReader.name}</div>
                    <div className="text-[11px] text-slate-500">
                      {selectedReader.category} • Matrícula: {selectedReader.enrollmentId}
                    </div>
                    <div className="mt-1 flex gap-2">
                      <span className="text-emerald-700 font-medium">
                        Empréstimos ativos: {selectedReader.activeLoansCount}
                      </span>
                      {selectedReader.finesBalance > 0 && (
                        <span className="text-red-700 font-bold">
                          Multas: R$ {selectedReader.finesBalance.toFixed(2)}
                        </span>
                      )}
                    </div>
                  </div>
                )}
              </div>

              {/* Exemplar */}
              <div>
                <label className="block text-xs font-semibold mb-1 text-slate-700" htmlFor="exemplar-input">
                  Código de Barras do Exemplar
                </label>
                <input
                  id="exemplar-input"
                  type="text"
                  value={selectedBookBarcode}
                  onChange={(e) => setSelectedBookBarcode(e.target.value)}
                  placeholder="Ex: 202600124"
                  className="w-full"
                />
                <div className="mt-2 text-xs text-slate-500">
                  Exemplar selecionado: <strong>O pequeno príncipe</strong> (Estante A3)
                </div>
              </div>

              {/* Prazo e Ação */}
              <div>
                <label className="block text-xs font-semibold mb-1 text-slate-700" htmlFor="prazo-select">
                  Prazo de Devolução
                </label>
                <select
                  id="prazo-select"
                  value={loanDays}
                  onChange={(e) => setLoanDays(Number(e.target.value))}
                  className="w-full"
                >
                  <option value={7}>7 dias (Revistas e Periódicos)</option>
                  <option value={14}>14 dias (Padrão para Alunos)</option>
                  <option value={30}>30 dias (Professores e Funcionários)</option>
                </select>

                <div className="mt-4">
                  <a
                    className="main_button w-full cursor-pointer text-center block"
                    onClick={handleCreateLoan}
                  >
                    Confirmar Empréstimo
                  </a>
                </div>
              </div>
            </div>
          </fieldset>

          {/* Active Loans Table */}
          <div className="page_title mt-6">
            <div className="text contains_subtext">
              Empréstimos em Andamento ({activeLoans.length})
              <div className="subtext">Acompanhamento de devoluções e alertas de atraso</div>
            </div>
            <div className="clear"></div>
          </div>

          <table className="holdings_table mt-3">
            <thead>
              <tr>
                <th>Cód. Barras</th>
                <th>Livro / Título</th>
                <th>Leitor (Aluno / Professor)</th>
                <th>Data Empréstimo</th>
                <th>Data Devolução</th>
                <th>Situação</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              {activeLoans.map((loan) => (
                <tr key={loan.id} className={loan.isOverdue ? 'bg-red-50/40' : ''}>
                  <td className="font-mono font-semibold">{loan.barcode}</td>
                  <td className="font-semibold text-slate-800">{loan.bookTitle}</td>
                  <td>
                    <div>{loan.readerName}</div>
                    <div className="text-[11px] text-slate-400">Matrícula: {loan.readerEnrollment}</div>
                  </td>
                  <td>{loan.loanDate}</td>
                  <td className={loan.isOverdue ? 'text-red-700 font-bold' : ''}>{loan.dueDate}</td>
                  <td>
                    {loan.isOverdue ? (
                      <span className="status_pill overdue">
                        Atrasado ({loan.daysOverdue} dias)
                      </span>
                    ) : (
                      <span className="status_pill borrowed">No prazo</span>
                    )}
                  </td>
                  <td>
                    <div className="flex items-center gap-1.5">
                      <a
                        className="button cursor-pointer text-xs"
                        onClick={() => handleReturnBook(loan.id)}
                        title="Registrar devolução"
                      >
                        Devolver
                      </a>
                      <a
                        className="faded_button cursor-pointer text-xs"
                        onClick={() => handleRenewLoan(loan.id)}
                        title="Renovar empréstimo"
                      >
                        Renovar
                      </a>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div id="copyright">Biblivre 5 — Software Livre para Gestão de Bibliotecas Escolares</div>
      </div>
    </div>
  );
}

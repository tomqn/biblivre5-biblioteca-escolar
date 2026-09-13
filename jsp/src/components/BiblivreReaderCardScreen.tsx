import { useState } from 'react';
import { SAMPLE_READERS } from '../data/mockBiblivreData';
import { Reader } from '../types';
import { Printer, Download, User, QrCode, Sparkles } from 'lucide-react';

interface BiblivreReaderCardScreenProps {
  libraryName: string;
  onShowMessage: (type: 'success' | 'warning', text: string) => void;
}

export function BiblivreReaderCardScreen({
  libraryName,
  onShowMessage,
}: BiblivreReaderCardScreenProps) {
  const [readers] = useState<Reader[]>(SAMPLE_READERS);
  const [selectedReader, setSelectedReader] = useState<Reader>(readers[0]);

  const handlePrint = () => {
    window.print();
    onShowMessage('success', `Carteirinha de ${selectedReader.name} enviada para impressão.`);
  };

  return (
    <div id="content_outer">
      <div id="content">
        <div id="content_inner">
          <div className="page_help">
            Carteirinha de Leitor da Biblioteca Escolar: Gere cartões de identificação de alunos e professores com código de barras para leitura rápida na bancada de atendimento.
          </div>

          <div className="page_title">
            <div className="text contains_subtext">
              Carteirinha de Leitor (Biblioteca Escolar)
              <div className="subtext">Identificação com foto, código de barras e matrícula</div>
            </div>
            <div className="clear"></div>
          </div>

          {/* Reader selector */}
          <div className="flex flex-wrap items-center gap-2 my-4">
            <label className="text-xs font-semibold text-slate-700">Selecione o leitor:</label>
            <div className="flex flex-wrap gap-1.5">
              {readers.map((r) => (
                <button
                  key={r.id}
                  onClick={() => setSelectedReader(r)}
                  className={`px-3 py-1 text-xs rounded-full border transition-colors cursor-pointer ${
                    selectedReader.id === r.id
                      ? 'bg-blue-600 text-white border-blue-600 font-semibold'
                      : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-100'
                  }`}
                >
                  {r.name} ({r.turma || 'Geral'})
                </button>
              ))}
            </div>
          </div>

          {/* Card Presentation Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-start my-6">
            {/* The Modern Reader Card (Printable) */}
            <div className="flex justify-center">
              <div className="reader_card">
                {/* Header */}
                <div className="reader_card_header">
                  <div>
                    <div className="reader_card_inst">{libraryName || 'Biblioteca Escolar'}</div>
                    <div className="text-[10px] text-slate-500 font-medium">Cartão de Acesso ao Acervo</div>
                  </div>
                  <div className="reader_card_category">
                    {selectedReader.category.includes('Aluno') ? 'Aluno' : 'Professor'}
                  </div>
                </div>

                {/* Body with Photo & Info */}
                <div className="reader_card_body">
                  <div className="reader_card_photo">
                    <User className="w-10 h-10 text-slate-400" />
                  </div>
                  <div className="reader_card_info">
                    <h4>{selectedReader.name}</h4>
                    <p className="text-xs">
                      <strong>Matrícula:</strong> {selectedReader.enrollmentId}
                    </p>
                    {selectedReader.turma && (
                      <p className="text-xs">
                        <strong>Turma:</strong> {selectedReader.turma}
                      </p>
                    )}
                    <p className="text-xs">
                      <strong>Validade:</strong> {selectedReader.validUntil}
                    </p>
                  </div>
                </div>

                {/* Barcode representation */}
                <div className="reader_card_barcode">
                  <div className="font-mono text-sm tracking-[0.25em] font-bold text-slate-800">
                    *{selectedReader.enrollmentId}*
                  </div>
                  {/* Simulated barcode stripes */}
                  <div className="flex justify-center gap-0.5 mt-1 h-8 items-stretch">
                    {Array.from({ length: 42 }).map((_, i) => (
                      <div
                        key={i}
                        className={`bg-slate-800 ${i % 3 === 0 ? 'w-1' : i % 5 === 0 ? 'w-1.5' : 'w-0.5'}`}
                      ></div>
                    ))}
                  </div>
                  <div className="text-[10px] text-slate-400 mt-1">Uso intransferível no recinto escolar</div>
                </div>
              </div>
            </div>

            {/* Reader Details & Actions */}
            <div className="space-y-4 bg-slate-50 p-5 rounded-xl border border-slate-200">
              <h3 className="font-bold text-slate-800 text-base">Dados Cadastrais do Leitor</h3>

              <div className="space-y-2 text-xs text-slate-700">
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="font-semibold text-slate-500">Nome Completo:</span>
                  <span className="font-medium text-slate-900">{selectedReader.name}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="font-semibold text-slate-500">Categoria:</span>
                  <span>{selectedReader.category}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="font-semibold text-slate-500">Turma / Turno:</span>
                  <span>{selectedReader.turma || 'Não especificado'}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="font-semibold text-slate-500">E-mail:</span>
                  <span>{selectedReader.email}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="font-semibold text-slate-500">Telefone:</span>
                  <span>{selectedReader.phone}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="font-semibold text-slate-500">Situação no Biblivre:</span>
                  <span className="text-emerald-700 font-bold">{selectedReader.status}</span>
                </div>
              </div>

              <div className="footer_buttons pt-3">
                <a className="main_button cursor-pointer" onClick={handlePrint}>
                  Imprimir Carteirinha
                </a>
                <a
                  className="button cursor-pointer"
                  onClick={() => onShowMessage('success', 'PDF da carteirinha gerado para download.')}
                >
                  Baixar em PDF
                </a>
              </div>
            </div>
          </div>
        </div>
        <div id="copyright">Biblivre 5 — Software Livre para Gestão de Bibliotecas Escolares</div>
      </div>
    </div>
  );
}

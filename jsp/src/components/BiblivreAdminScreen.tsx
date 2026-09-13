import { useState } from 'react';
import { Palette, Shield, Sliders, Database, Check } from 'lucide-react';

interface BiblivreAdminScreenProps {
  libraryName: string;
  onUpdateLibraryName: (name: string) => void;
  onShowMessage: (type: 'success' | 'warning', text: string) => void;
}

export function BiblivreAdminScreen({
  libraryName,
  onUpdateLibraryName,
  onShowMessage,
}: BiblivreAdminScreenProps) {
  const [nameInput, setNameInput] = useState(libraryName);
  const [schoolName, setSchoolName] = useState('Escola Estadual Cecília Meireles');
  const [maxLoanDays, setMaxLoanDays] = useState(14);
  const [maxBooksPerStudent, setMaxBooksPerStudent] = useState(3);
  const [dailyFine, setDailyFine] = useState('1,00');

  // Color theme presets
  const [selectedColor, setSelectedColor] = useState('#2563eb');

  const colorPresets = [
    { name: 'Azul Escolar (Padrão)', hex: '#2563eb' },
    { name: 'Verde Esmeralda', hex: '#059669' },
    { name: 'Vinho Clássico', hex: '#991b1b' },
    { name: 'Azul Noturno Profundo', hex: '#0f172a' },
  ];

  const handleApplyColor = (hex: string) => {
    setSelectedColor(hex);
    document.documentElement.style.setProperty('--bb-brand-600', hex);
    document.documentElement.style.setProperty('--bb-brand-700', hex);
    onShowMessage('success', `Cor primária do Biblivre atualizada para ${hex}!`);
  };

  const handleSaveConfigs = () => {
    onUpdateLibraryName(nameInput);
    onShowMessage('success', 'Configurações do Biblivre 5 salvas com sucesso!');
  };

  return (
    <div id="content_outer">
      <div id="content">
        <div id="content_inner">
          <div className="page_help">
            Módulo de Administração: Personalize o nome da biblioteca da sua escola, configure limites de empréstimo, multas e gerencie a matriz de permissões dos usuários.
          </div>

          <div className="page_title">
            <div className="text contains_subtext">
              Administração & Configurações da Biblioteca Escolar
              <div className="subtext">Identidade visual, regras de circulação e controle de acesso</div>
            </div>
            <div className="clear"></div>
          </div>

          {/* Configuration Sections */}
          <div className="space-y-6 mt-4">
            {/* 1. Identity & Branding */}
            <fieldset className="block">
              <legend>Identidade da Biblioteca e Escola</legend>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-2">
                <div>
                  <label className="block text-xs font-semibold mb-1 text-slate-700">
                    Nome da Biblioteca Escolar
                  </label>
                  <input
                    type="text"
                    value={nameInput}
                    onChange={(e) => setNameInput(e.target.value)}
                    className="w-full"
                    placeholder="Ex: Biblioteca Escolar Cecília Meireles"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold mb-1 text-slate-700">
                    Nome da Instituição de Ensino
                  </label>
                  <input
                    type="text"
                    value={schoolName}
                    onChange={(e) => setSchoolName(e.target.value)}
                    className="w-full"
                  />
                </div>
              </div>

              {/* Color customizer */}
              <div className="mt-4 pt-3 border-t border-slate-200">
                <label className="block text-xs font-semibold mb-2 text-slate-700">
                  Paleta de Cor Primária (Tema Moderno)
                </label>
                <div className="flex flex-wrap gap-2">
                  {colorPresets.map((c) => (
                    <button
                      key={c.hex}
                      onClick={() => handleApplyColor(c.hex)}
                      className={`flex items-center gap-2 px-3 py-1.5 rounded-lg border text-xs font-medium cursor-pointer transition-all ${
                        selectedColor === c.hex
                          ? 'border-slate-800 ring-2 ring-slate-400 bg-white shadow-sm'
                          : 'border-slate-300 bg-slate-50 hover:bg-white'
                      }`}
                    >
                      <span className="w-4 h-4 rounded-full" style={{ backgroundColor: c.hex }}></span>
                      <span>{c.name}</span>
                    </button>
                  ))}
                </div>
              </div>
            </fieldset>

            {/* 2. Circulation Rules */}
            <fieldset className="block">
              <legend>Políticas de Circulação e Empréstimo</legend>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-2">
                <div>
                  <label className="block text-xs font-semibold mb-1 text-slate-700">
                    Prazo Padrão de Empréstimo (Dias)
                  </label>
                  <input
                    type="number"
                    value={maxLoanDays}
                    onChange={(e) => setMaxLoanDays(Number(e.target.value))}
                    className="w-full"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold mb-1 text-slate-700">
                    Limite de Livros por Aluno
                  </label>
                  <input
                    type="number"
                    value={maxBooksPerStudent}
                    onChange={(e) => setMaxBooksPerStudent(Number(e.target.value))}
                    className="w-full"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold mb-1 text-slate-700">
                    Multa Diária por Atraso (R$)
                  </label>
                  <input
                    type="text"
                    value={dailyFine}
                    onChange={(e) => setDailyFine(e.target.value)}
                    className="w-full"
                  />
                </div>
              </div>
            </fieldset>

            {/* 3. Permissions Matrix */}
            <fieldset className="block">
              <legend>Matriz de Permissões de Acesso</legend>
              <div className="overflow-x-auto mt-2">
                <table className="permission_grid">
                  <thead>
                    <tr>
                      <th>Perfil de Usuário</th>
                      <th>Pesquisa (OPAC)</th>
                      <th>Circulação (Empréstimos)</th>
                      <th>Catalogação & MARC</th>
                      <th>Aquisições</th>
                      <th>Administração</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Administrador do Sistema</td>
                      <td><input type="checkbox" defaultChecked disabled /></td>
                      <td><input type="checkbox" defaultChecked disabled /></td>
                      <td><input type="checkbox" defaultChecked disabled /></td>
                      <td><input type="checkbox" defaultChecked disabled /></td>
                      <td><input type="checkbox" defaultChecked disabled /></td>
                    </tr>
                    <tr>
                      <td>Bibliotecário(a)</td>
                      <td><input type="checkbox" defaultChecked /></td>
                      <td><input type="checkbox" defaultChecked /></td>
                      <td><input type="checkbox" defaultChecked /></td>
                      <td><input type="checkbox" defaultChecked /></td>
                      <td><input type="checkbox" /></td>
                    </tr>
                    <tr>
                      <td>Auxiliar de Biblioteca</td>
                      <td><input type="checkbox" defaultChecked /></td>
                      <td><input type="checkbox" defaultChecked /></td>
                      <td><input type="checkbox" defaultChecked /></td>
                      <td><input type="checkbox" /></td>
                      <td><input type="checkbox" /></td>
                    </tr>
                    <tr>
                      <td>Professor / Docente</td>
                      <td><input type="checkbox" defaultChecked /></td>
                      <td><input type="checkbox" /></td>
                      <td><input type="checkbox" /></td>
                      <td><input type="checkbox" /></td>
                      <td><input type="checkbox" /></td>
                    </tr>
                    <tr>
                      <td>Aluno / Comunidade Escolar</td>
                      <td><input type="checkbox" defaultChecked /></td>
                      <td><input type="checkbox" /></td>
                      <td><input type="checkbox" /></td>
                      <td><input type="checkbox" /></td>
                      <td><input type="checkbox" /></td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </fieldset>

            <div className="footer_buttons">
              <a className="main_button cursor-pointer" onClick={handleSaveConfigs}>
                Salvar Configurações
              </a>
              <a
                className="button cursor-pointer"
                onClick={() => onShowMessage('success', 'Backup integral do banco de dados Biblivre gerado (b5z).')}
              >
                Criar Ponto de Restauração / Backup
              </a>
            </div>
          </div>
        </div>
        <div id="copyright">Biblivre 5 — Software Livre para Gestão de Bibliotecas Escolares</div>
      </div>
    </div>
  );
}

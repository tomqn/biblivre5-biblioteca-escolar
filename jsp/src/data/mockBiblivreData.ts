import { BookRecord, MarcField, HoldingCopy, Reader, ActiveLoan } from '../types';

export const INITIAL_BOOKS: BookRecord[] = [
  {
    id: 1,
    title: 'O pequeno príncipe',
    author: 'Saint-Exupéry, Antoine de',
    year: 2018,
    shelfLocation: '843 S145p',
    isbn: '978-85-01-11234-5',
    publisher: 'Agir (Rio de Janeiro)',
    subject: 'Literatura infantojuvenil',
    materialType: 'Livro',
    totalCopies: 6,
    availableCopies: 4,
    borrowedCopies: 2,
    reservedCopies: 0,
    coverColor: '#3b82f6',
    summary: 'A história do piloto que cai no deserto do Saara e encontra um jovem príncipe vindo de um asteroide distante, abordando temas de amizade, responsabilidade e afeto.'
  },
  {
    id: 2,
    title: 'Mitologia grega para jovens leitores',
    author: 'Menezes, Clara',
    year: 2021,
    shelfLocation: '292 M543m',
    isbn: '978-85-35-93412-1',
    publisher: 'Companhia das Letras',
    subject: 'Mitologia',
    materialType: 'Livro',
    totalCopies: 3,
    availableCopies: 0,
    borrowedCopies: 3,
    reservedCopies: 1,
    coverColor: '#8b5cf6',
    summary: 'Uma introdução ilustrada e dinâmica aos principais mitos e deuses do Olimpo grego, contextualizados para o público escolar.'
  },
  {
    id: 3,
    title: 'Dom Casmurro',
    author: 'Assis, Machado de',
    year: 2019,
    shelfLocation: '869.3 A848d',
    isbn: '978-85-72-32812-7',
    publisher: 'Penguin Classics / Companhia',
    subject: 'Ficção brasileira',
    materialType: 'Livro',
    totalCopies: 8,
    availableCopies: 5,
    borrowedCopies: 2,
    reservedCopies: 1,
    coverColor: '#059669',
    summary: 'Bentinho narra sua história de amor por Capitu e as suspeitas de traição com seu melhor amigo Escobar no clássico maior do Realismo brasileiro.'
  },
  {
    id: 4,
    title: 'Capitães da Areia',
    author: 'Amado, Jorge',
    year: 2017,
    shelfLocation: '869.3 A481c',
    isbn: '978-85-35-91166-5',
    publisher: 'Companhia das Letras',
    subject: 'Romance social brasileiro',
    materialType: 'Livro',
    totalCopies: 5,
    availableCopies: 3,
    borrowedCopies: 2,
    reservedCopies: 0,
    coverColor: '#d97706',
    summary: 'O cotidiano de um grupo de meninos abandonados que habitam um trapiche abandonado em Salvador, lutando pela sobrevivência e pela liberdade.'
  },
  {
    id: 5,
    title: 'A Hora da Estrela',
    author: 'Lispector, Clarice',
    year: 2020,
    shelfLocation: '869.3 L769h',
    isbn: '978-85-32-53093-4',
    publisher: 'Rocco',
    subject: 'Literatura contemporânea',
    materialType: 'Livro',
    totalCopies: 4,
    availableCopies: 2,
    borrowedCopies: 2,
    reservedCopies: 0,
    coverColor: '#dc2626',
    summary: 'Último livro de Clarice Lispector, que relata as desventuras da jovem alagoana Macabéa no Rio de Janeiro pelo olhar do narrador Rodrigo S.M.'
  },
  {
    id: 6,
    title: 'O Menino Maluquinho',
    author: 'Ziraldo',
    year: 2016,
    shelfLocation: '869.3 Z81m',
    isbn: '978-85-06-00001-4',
    publisher: 'Melhoramentos',
    subject: 'Literatura infantojuvenil brasileira',
    materialType: 'Livro',
    totalCopies: 7,
    availableCopies: 6,
    borrowedCopies: 1,
    reservedCopies: 0,
    coverColor: '#0284c7',
    summary: 'As travessuras do menino que tinha vento nos pés, panela na cabeça e um coração do tamanho do mundo.'
  }
];

export const SAMPLE_MARC_RECORD: MarcField[] = [
  { tag: '008', ind1: ' ', ind2: ' ', subfields: [{ code: 'a', value: '180512s2018    bl            000 0 por d' }] },
  { tag: '020', ind1: ' ', ind2: ' ', subfields: [{ code: 'a', value: '9788501112345' }, { code: 'c', value: 'R$ 39,90' }] },
  { tag: '040', ind1: ' ', ind2: ' ', subfields: [{ code: 'a', value: 'BR-RjBES' }, { code: 'b', value: 'por' }, { code: 'c', value: 'BR-RjBES' }] },
  { tag: '082', ind1: '0', ind2: '4', subfields: [{ code: 'a', value: '843' }] },
  { tag: '090', ind1: ' ', ind2: ' ', subfields: [{ code: 'a', value: '843 S145p' }] },
  { tag: '100', ind1: '1', ind2: ' ', subfields: [{ code: 'a', value: 'Saint-Exupéry, Antoine de,' }, { code: 'd', value: '1900-1944' }] },
  { tag: '245', ind1: '1', ind2: '2', subfields: [{ code: 'a', value: 'O pequeno príncipe /' }, { code: 'c', value: 'Antoine de Saint-Exupéry ; tradução de Dom Marcos Barbosa.' }] },
  { tag: '250', ind1: ' ', ind2: ' ', subfields: [{ code: 'a', value: '54. ed.' }] },
  { tag: '260', ind1: ' ', ind2: ' ', subfields: [{ code: 'a', value: 'Rio de Janeiro :' }, { code: 'b', value: 'Agir,' }, { code: 'c', value: '2018.' }] },
  { tag: '300', ind1: ' ', ind2: ' ', subfields: [{ code: 'a', value: '96 p. :' }, { code: 'b', value: 'il. color. ;' }, { code: 'c', value: '21 cm.' }] },
  { tag: '500', ind1: ' ', ind2: ' ', subfields: [{ code: 'a', value: 'Título original: Le petit prince.' }] },
  { tag: '650', ind1: ' ', ind2: '4', subfields: [{ code: 'a', value: 'Literatura infantojuvenil' }] },
  { tag: '650', ind1: ' ', ind2: '4', subfields: [{ code: 'a', value: 'Amizade' }, { code: 'x', value: 'Ficção' }] },
  { tag: '700', ind1: '1', ind2: ' ', subfields: [{ code: 'a', value: 'Barbosa, Marcos,' }, { code: 'd', value: '1915-1997,' }, { code: 'e', value: 'tradutor.' }] }
];

export const SAMPLE_HOLDINGS: HoldingCopy[] = [
  { id: 'EXP-00124', barcode: '202600124', volume: 'v. 1', shelf: '843 S145p - Estante A3', acquisitionDate: '14/02/2022', status: 'available' },
  { id: 'EXP-00125', barcode: '202600125', volume: 'v. 1', shelf: '843 S145p - Estante A3', acquisitionDate: '14/02/2022', status: 'available' },
  { id: 'EXP-00126', barcode: '202600126', volume: 'v. 1', shelf: '843 S145p - Estante A3', acquisitionDate: '14/02/2022', status: 'borrowed', borrowerName: 'Lucas Ferreira (Turma 802)', dueDate: '18/09/2026' },
  { id: 'EXP-00127', barcode: '202600127', volume: 'v. 1', shelf: '843 S145p - Estante A3', acquisitionDate: '14/02/2022', status: 'borrowed', borrowerName: 'Beatriz Lima (Turma 901)', dueDate: '10/09/2026' },
  { id: 'EXP-00128', barcode: '202600128', volume: 'v. 1', shelf: '843 S145p - Estante A3', acquisitionDate: '20/05/2023', status: 'available' },
  { id: 'EXP-00129', barcode: '202600129', volume: 'v. 1', shelf: '843 S145p - Estante A3', acquisitionDate: '20/05/2023', status: 'available' }
];

export const SAMPLE_READERS: Reader[] = [
  {
    id: 'ALU-2026042',
    name: 'Mariana Souza Santos',
    enrollmentId: '2026042',
    category: 'Aluno - Ensino Fundamental',
    turma: '9º Ano B',
    email: 'mariana.santos@escola.edu.br',
    phone: '(11) 98452-1144',
    activeLoansCount: 1,
    finesBalance: 0.0,
    status: 'Ativo',
    validUntil: '15/12/2026'
  },
  {
    id: 'ALU-2026089',
    name: 'Lucas Ferreira Alves',
    enrollmentId: '2026089',
    category: 'Aluno - Ensino Médio',
    turma: '2ª Série EM A',
    email: 'lucas.alves@escola.edu.br',
    phone: '(11) 97123-9988',
    activeLoansCount: 2,
    finesBalance: 0.0,
    status: 'Ativo',
    validUntil: '15/12/2026'
  },
  {
    id: 'ALU-2025114',
    name: 'Beatriz Lima Rocha',
    enrollmentId: '2025114',
    category: 'Aluno - Ensino Fundamental',
    turma: '8º Ano A',
    email: 'beatriz.rocha@escola.edu.br',
    phone: '(11) 99341-2255',
    activeLoansCount: 1,
    finesBalance: 2.5,
    status: 'Ativo',
    validUntil: '15/12/2026'
  },
  {
    id: 'PROF-1004',
    name: 'Prof. Carlos Eduardo Silveira',
    enrollmentId: 'PROF-1004',
    category: 'Professor',
    turma: 'Língua Portuguesa',
    email: 'carlos.silveira@escola.edu.br',
    phone: '(11) 99112-3344',
    activeLoansCount: 3,
    finesBalance: 0.0,
    status: 'Ativo',
    validUntil: '31/12/2027'
  }
];

export const INITIAL_ACTIVE_LOANS: ActiveLoan[] = [
  {
    id: 'LOAN-1082',
    bookTitle: 'O pequeno príncipe',
    barcode: '202600126',
    readerName: 'Lucas Ferreira Alves',
    readerEnrollment: '2026089',
    loanDate: '04/09/2026',
    dueDate: '18/09/2026',
    isOverdue: false
  },
  {
    id: 'LOAN-1075',
    bookTitle: 'O pequeno príncipe',
    barcode: '202600127',
    readerName: 'Beatriz Lima Rocha',
    readerEnrollment: '2025114',
    loanDate: '27/08/2026',
    dueDate: '10/09/2026',
    isOverdue: true,
    daysOverdue: 2
  },
  {
    id: 'LOAN-1090',
    bookTitle: 'Mitologia grega para jovens leitores',
    barcode: '202600210',
    readerName: 'Mariana Souza Santos',
    readerEnrollment: '2026042',
    loanDate: '08/09/2026',
    dueDate: '22/09/2026',
    isOverdue: false
  },
  {
    id: 'LOAN-1060',
    bookTitle: 'Capitães da Areia',
    barcode: '202600344',
    readerName: 'Prof. Carlos Eduardo Silveira',
    readerEnrollment: 'PROF-1004',
    loanDate: '15/08/2026',
    dueDate: '15/09/2026',
    isOverdue: false
  }
];

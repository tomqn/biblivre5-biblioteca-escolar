export type BiblivreScreen =
  | 'search'
  | 'cataloging'
  | 'circulation'
  | 'reader_card'
  | 'administration';

export interface BookRecord {
  id: number;
  title: string;
  author: string;
  year: number;
  shelfLocation: string; // ex: "843 S145p"
  isbn: string;
  publisher: string;
  subject: string;
  materialType: 'Livro' | 'Periódico' | 'Material Especial' | 'Tese';
  totalCopies: number;
  availableCopies: number;
  borrowedCopies: number;
  reservedCopies: number;
  coverColor?: string;
  summary?: string;
}

export interface MarcField {
  tag: string;
  ind1: string;
  ind2: string;
  subfields: { code: string; value: string }[];
}

export interface HoldingCopy {
  id: string;
  barcode: string;
  volume: string;
  shelf: string;
  acquisitionDate: string;
  status: 'available' | 'borrowed' | 'reserved' | 'overdue';
  borrowerName?: string;
  dueDate?: string;
}

export interface Reader {
  id: string;
  name: string;
  enrollmentId: string; // Matrícula escolar
  category: 'Aluno - Ensino Fundamental' | 'Aluno - Ensino Médio' | 'Professor' | 'Funcionário';
  turma?: string;
  email: string;
  phone: string;
  activeLoansCount: number;
  finesBalance: number;
  status: 'Ativo' | 'Bloqueado';
  validUntil: string;
}

export interface ActiveLoan {
  id: string;
  bookTitle: string;
  barcode: string;
  readerName: string;
  readerEnrollment: string;
  loanDate: string;
  dueDate: string;
  isOverdue: boolean;
  daysOverdue?: number;
}

import 'package:uuid/uuid.dart';

import '../models/enums.dart';
import '../models/models.dart';

const _uuid = Uuid();

/// Semestre mockado da FIAP, coerente com 21/09/2026 (segunda-feira).
class MockData {
  static const student = Student(
    name: 'Hercules Ramos',
    course: 'Engenharia de Software',
    rm: 'RM562354',
    institution: 'FIAP',
  );

  static List<Delivery> deliveries() {
    return [
      Delivery(
        id: _uuid.v4(),
        title: 'Checkpoint 1',
        discipline: 'Redes Neurais',
        dueDate: DateTime(2026, 9, 10),
        priority: TaskPriority.media,
        status: DeliveryStatus.concluida,
        notes: 'Modelo de classificação entregue no Moodle.',
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Lista de exercícios',
        discipline: 'Data-Science',
        dueDate: DateTime(2026, 9, 12),
        priority: TaskPriority.baixa,
        status: DeliveryStatus.concluida,
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Leitura obrigatória',
        discipline: 'Redes Neurais',
        dueDate: DateTime(2026, 9, 14),
        priority: TaskPriority.baixa,
        notes: 'Capítulos 3 e 4 do material da semana.',
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Infográfico do sprint',
        discipline: 'Data-Science',
        dueDate: DateTime(2026, 9, 17),
        priority: TaskPriority.media,
        notes: 'Ainda pendente. Já passou do prazo.',
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Quiz semanal',
        discipline: 'Cross-Platform',
        dueDate: DateTime(2026, 9, 20),
        priority: TaskPriority.baixa,
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Projeto Figma',
        discipline: 'Cross-Platform',
        dueDate: DateTime(2026, 9, 23),
        priority: TaskPriority.alta,
        notes: 'Protótipo de alta fidelidade do ROTA, alinhado ao CP4.',
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Checkpoint 2',
        discipline: 'Cross-Platform',
        dueDate: DateTime(2026, 9, 24),
        priority: TaskPriority.alta,
        notes: 'Protótipo funcional navegável.',
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Checkpoint 2',
        discipline: 'Redes Neurais',
        dueDate: DateTime(2026, 9, 25),
        priority: TaskPriority.alta,
        notes: 'Ajuste do modelo e relatório de métricas.',
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Global Solution',
        discipline: 'Cross-Platform',
        dueDate: DateTime(2026, 9, 26),
        priority: TaskPriority.alta,
        notes: 'Entrega parcial da solução integrada.',
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Projeto de Dados',
        discipline: 'Data-Science',
        dueDate: DateTime(2026, 10, 2),
        priority: TaskPriority.media,
        notes: 'Pipeline e visualização do dataset acadêmico.',
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Seminário de acompanhamento',
        discipline: 'Cross-Platform',
        dueDate: DateTime(2026, 10, 4),
        priority: TaskPriority.baixa,
        notes: 'Alinhamento curto com o professor orientador.',
      ),
      Delivery(
        id: _uuid.v4(),
        title: 'Projeto Chatbot',
        discipline: 'Redes Neurais',
        dueDate: DateTime(2026, 10, 23),
        priority: TaskPriority.baixa,
        notes: 'Primeira versão conversacional para tirar dúvidas da disciplina.',
      ),
    ];
  }
}

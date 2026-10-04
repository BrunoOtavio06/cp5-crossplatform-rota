import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

enum TaskPriority {
  baixa,
  media,
  alta;

  String get label => switch (this) {
        TaskPriority.baixa => 'Baixa',
        TaskPriority.media => 'Média',
        TaskPriority.alta => 'Alta',
      };

  int get weight => switch (this) {
        TaskPriority.baixa => 1,
        TaskPriority.media => 2,
        TaskPriority.alta => 3,
      };

  Color get color => switch (this) {
        TaskPriority.baixa => AppColors.success,
        TaskPriority.media => AppColors.medium,
        TaskPriority.alta => AppColors.high,
      };

  static TaskPriority fromStorage(String value) {
    return TaskPriority.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TaskPriority.media,
    );
  }
}

enum DeliveryStatus {
  pendente,
  concluida;

  String get label => switch (this) {
        DeliveryStatus.pendente => 'Pendente',
        DeliveryStatus.concluida => 'Concluída',
      };

  static DeliveryStatus fromStorage(String value) {
    return DeliveryStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => DeliveryStatus.pendente,
    );
  }
}

enum LoadLevel {
  leve,
  media,
  alta,
  critica;

  String get label => switch (this) {
        LoadLevel.leve => 'Leve',
        LoadLevel.media => 'Média',
        LoadLevel.alta => 'Alta',
        LoadLevel.critica => 'Crítica',
      };

  Color get barColor => switch (this) {
        LoadLevel.leve => AppColors.success,
        LoadLevel.media => AppColors.medium,
        LoadLevel.alta => AppColors.warning,
        LoadLevel.critica => AppColors.high,
      };
}

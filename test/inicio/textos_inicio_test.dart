import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/sugestao.dart';
import 'package:petamigo/features/diario/domain/entidades/resumo_dia.dart';
import 'package:petamigo/features/inicio/data/sugestoes_adiadas_config.dart';
import 'package:petamigo/features/inicio/domain/textos_inicio.dart';
import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';
import 'package:petamigo/features/nutricao/domain/meta_diaria.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';
import 'package:petamigo/features/privacidade/domain/entidades/estado_copia.dart';

import '../apoio/pets_falsos.dart';

Lembrete lembrete(int minutos, {bool ativo = true}) => Lembrete(
  id: 'l$minutos',
  petId: 'p1',
  horaMinutos: minutos,
  tipo: TipoLembrete.refeicao,
  ativo: ativo,
  notificacaoId: minutos,
);

void main() {
  final hoje = DateTime(2026, 9, 30);

  group('card do pet', () {
    test('Luna com pesagem: como no PNG 01', () {
      expect(textoPerfil(luna(), 5.4, hoje), 'Gata • 6 anos • castrada\nAtividade moderada • 5,4 kg');
    });

    test('sem pesagem: peso não informado', () {
      expect(textoPerfil(luna(), null, hoje), endsWith('Atividade moderada • peso não informado'));
    });

    test('macho não castrado com atividade alta', () {
      final thor = luna().copyWith(
        especie: Especie.cao,
        sexo: Sexo.macho,
        castrado: false,
        nivelAtividade: NivelAtividade.alta,
      );
      expect(textoPerfil(thor, 12, hoje), 'Cão • 6 anos • não castrado\nAtividade alta • 12,0 kg');
    });
  });

  group('R02 — card "Hoje"', () {
    final resumo = ResumoDia(dia: hoje, racaoKcal: 108, extrasKcal: 12, registros: 3);

    test('sem registros', () {
      expect(textoHoje(ResumoDia.vazio(hoje), metaDiaria(luna(), 5.4, hoje)), 'Ainda sem registros hoje.');
    });

    test('com meta: Total: 120 de 397 kcal', () {
      expect(
        textoHoje(resumo, metaDiaria(luna(), 5.4, hoje)),
        'Ração 108 kcal • Petiscos 12 kcal\nTotal: 120 de 397 kcal',
      );
    });

    test('sem meta (sem pesagem ou carregando): Total registrado', () {
      const esperado = 'Ração 108 kcal • Petiscos 12 kcal\nTotal registrado: 120 kcal';
      expect(textoHoje(resumo, metaDiaria(luna(), null, hoje)), esperado);
      expect(textoHoje(resumo, null), esperado);
    });
  });

  group('card "Lembretes"', () {
    test('só os ativos, em ordem, sem repetir', () {
      expect(
        textoLembretes([lembrete(1200), lembrete(480), lembrete(840), lembrete(600, ativo: false), lembrete(480)]),
        '08:00 • 14:00 • 20:00',
      );
    });

    test('nenhum ativo', () {
      expect(textoLembretes([lembrete(480, ativo: false)]), 'Nenhum lembrete ativo.');
      expect(textoLembretes(const []), 'Nenhum lembrete ativo.');
    });
  });

  test('card "Seu controle"', () {
    expect(textoSeuControle(const CopiaDesligada()), 'Dados salvos neste aparelho.');
    expect(textoSeuControle(const CopiaPendente(3)), 'Cópia remota: pendente');
    expect(textoSeuControle(CopiaSincronizada(hoje)), 'Cópia remota: sincronizado');
    expect(textoSeuControle(const CopiaComFalha()), 'Cópia remota: falha');
    expect(textoSeuControle(const CopiaComConflito(1)), 'Cópia remota: pendente');
  });

  test('ação de cada sugestão (M8)', () {
    expect(textoAcaoSugestao(TipoSugestao.reduzirPetiscos), 'Ver diário');
    expect(textoAcaoSugestao(TipoSugestao.aumentarExercicios), 'Ver atividades');
    expect(textoAcaoSugestao(TipoSugestao.mudarObjetivo), 'Ver evolução');
  });

  group('sugestões adiadas em config (JSON)', () {
    test('ida e volta', () {
      final adiadas = {
        TipoSugestao.reduzirPetiscos: DateTime(2026, 9, 30),
        TipoSugestao.mudarObjetivo: DateTime(2026, 10, 2),
      };
      final json = gravarAdiadas(adiadas);
      expect(json, '{"reduzirPetiscos":"2026-09-30","mudarObjetivo":"2026-10-02"}');
      expect(lerAdiadas(json), adiadas);
    });

    test('vazio, JSON quebrado, tipo desconhecido e data ruim viram nada', () {
      expect(lerAdiadas(null), isEmpty);
      expect(lerAdiadas(''), isEmpty);
      expect(lerAdiadas('{'), isEmpty);
      expect(lerAdiadas('[1]'), isEmpty);
      expect(lerAdiadas('{"outra":"2026-09-30","reduzirPetiscos":"ontem"}'), isEmpty);
    });
  });
}

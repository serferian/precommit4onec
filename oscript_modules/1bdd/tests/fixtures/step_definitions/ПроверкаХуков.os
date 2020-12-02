﻿// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd

Перем БДД; //контекст фреймворка 1bdd

// Метод выдает список шагов, реализованных в данном файле-шагов
Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	БДД = КонтекстФреймворкаBDD;

	ВсеШаги = Новый Массив;

	ВсеШаги.Добавить("ЯЗаписываюВФайлЖурнала");

	Возврат ВсеШаги;
КонецФункции

Процедура ПередЗапускомСценария(Знач УзелОписанияСценария) Экспорт
	ЯЗаписываюВФайлЖурнала(СтрШаблон("ПередЗапускомСценария-%1", УзелОписанияСценария.Тело));
КонецПроцедуры

Процедура ПослеЗапускаСценария(Знач УзелОписанияСценария) Экспорт
	ЯЗаписываюВФайлЖурнала(СтрШаблон("ПослеЗапускаСценария-%1", УзелОписанияСценария.Тело));
КонецПроцедуры

// Реализация шагов

//я записываю "ШагСценария" в файл журнала
Процедура ЯЗаписываюВФайлЖурнала(Знач СтрокаДляЖурнала) Экспорт
	СтрокаИзЖурнала = ПрочитатьЖурнал();

	ЗаписьФайла = Новый ЗаписьТекста(ПутьФайлаЖурнала(), "utf-8");

	ЗаписьФайла.ЗаписатьСтроку(СтрШаблон("%1;%2", СтрокаИзЖурнала, СтрокаДляЖурнала));

	ЗаписьФайла.Закрыть();
КонецПроцедуры

Функция ПрочитатьЖурнал()
	ФайлЖурнала = Новый Файл(ПутьФайлаЖурнала());
	Если ФайлЖурнала.Существует() Тогда
		
		ЧтениеТекста = Новый ЧтениеТекста;
		ЧтениеТекста.Открыть(ПутьФайлаЖурнала(),"UTF-8");

		СтрокаИзЖурнала = ЧтениеТекста.ПрочитатьСтроку();
		ЧтениеТекста.Закрыть();
	Иначе
		СтрокаИзЖурнала = "";
	КонецЕсли;
	Возврат СтрокаИзЖурнала;
КонецФункции

Функция ПутьФайлаЖурнала()
	Возврат "ФайлЖурнала.log";
КонецФункции // ПутьФайлаЖурнала()

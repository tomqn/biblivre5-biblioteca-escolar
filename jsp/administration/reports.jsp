<%@page import="biblivre.circulation.user.UserFields"%>
<%@page import="biblivre.core.utils.Constants"%>
<%@page import="biblivre.core.configurations.Configurations"%>
<%@page import="biblivre.cataloging.Fields"%>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="biblivre.cataloging.enums.RecordDatabase"%>
<%@ taglib prefix="layout" uri="/WEB-INF/tlds/layout.tld" %>
<%@ taglib prefix="i18n" uri="/WEB-INF/tlds/translations.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<layout:head>
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.administration.css" />
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.search.css" />
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.circulation.css" />	
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.cataloging.css" />
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.modern.css" />
	
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
	
	<script type="text/javascript" src="static/scripts/zebra_datepicker.js"></script>
	<link rel="stylesheet" type="text/css" href="static/styles/zebra.bootstrap.css">
	
	<script type="text/javascript" src="static/scripts/biblivre.search.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.cataloging.search.js"></script>	
	<script type="text/javascript" src="static/scripts/biblivre.input.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.cataloging.input.js"></script>
	<script type="text/javascript" src="static/scripts/<%= Fields.getFormFields((String) request.getAttribute("schema"), "biblio").getCacheFileName() %>"></script>
	
	<script type="text/javascript" src="static/scripts/biblivre.circulation.search.js"></script>
	
	<script type="text/javascript" src="static/scripts/biblivre.administration.reports.js"></script>
	
	<script type="text/javascript">
		var CirculationSearch = CreateSearch(CirculationSearchClass, {
			type: 'circulation.user',
			root: '#userDiv',
			enableTabs: false,
			enableHistory: false
		});
	</script>
	
	<style type="text/css">
		/* =================================================================
		   PADRONIZAÇÃO MODERNA E COMPACTA (RELATÓRIOS ADMINISTRATIVOS)
		   Seguindo o design system merged no GitHub para Biblivre 5
		   ================================================================= */
		body, #biblivre_reports_form, #dateDiv, #databaseSelection, #orderDiv, #deweyDiv, #authorDiv, #fieldCountDiv, #catalogingDiv, #userDiv, #buttonDiv {
			font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif !important;
			color: #0f172a;
		}

		/* LARGURA E CENTRALIZAÇÃO */
		#biblivre_reports_form, #dateDiv, #databaseSelection, #orderDiv, #deweyDiv, #authorDiv, #fieldCountDiv, #catalogingDiv, #userDiv, #buttonDiv {
			max-width: 960px !important;
			margin: 0 auto 12px auto !important;
			box-sizing: border-box !important;
		}

		/* ZERA ESPAÇADORES LEGADOS */
		.ncspacer {
			display: none !important;
			height: 0 !important;
			margin: 0 !important;
		}

		/* AJUDA SUPERIOR */
		.page_help {
			background: #f8fafc !important;
			border: 1px solid #e2e8f0 !important;
			border-radius: 8px !important;
			color: #475569 !important;
			font-size: 12px !important;
			padding: 10px 16px !important;
			margin: 0 auto 14px auto !important;
			max-width: 960px !important;
			line-height: 1.5 !important;
			box-sizing: border-box !important;
		}

		/* FIELDSETS EM CARDS MODERNOS */
		fieldset.block.reports {
			background: #ffffff !important;
			border: 1px solid #e2e8f0 !important;
			border-radius: 10px !important;
			box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05) !important;
			padding: 16px 20px !important;
			box-sizing: border-box !important;
		}

		fieldset.block.reports legend {
			font-size: 13px !important;
			font-weight: 800 !important;
			color: #0f172a !important;
			padding: 0 8px !important;
			letter-spacing: -0.01em !important;
		}

		/* ÁREA PRINCIPAL DE SELEÇÃO DE RELATÓRIO */
		#reportSelection {
			padding: 8px 0 !important;
			text-align: center !important;
		}

		#reportSelection .title {
			font-size: 13px !important;
			font-weight: 700 !important;
			color: #334155 !important;
			margin-bottom: 8px !important;
			display: block !important;
		}

		#reportSelect {
			width: 100% !important;
			max-width: 540px !important;
			height: 38px !important;
			border-radius: 6px !important;
			border: 1px solid #cbd5e1 !important;
			padding: 0 12px !important;
			font-size: 13px !important;
			font-weight: 600 !important;
			color: #0f172a !important;
			background: #ffffff !important;
			outline: none !important;
			box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04) !important;
			transition: border-color 0.2s, box-shadow 0.2s !important;
			margin: 0 auto !important;
			display: inline-block !important;
		}

		#reportSelect:focus {
			border-color: #2563eb !important;
			box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15) !important;
		}

		#reportSelect optgroup {
			font-weight: 700 !important;
			color: #0f172a !important;
			background: #f1f5f9 !important;
			padding: 6px 4px !important;
		}

		#reportSelect option {
			font-weight: 500 !important;
			color: #334155 !important;
			background: #ffffff !important;
			padding: 4px 8px !important;
		}

		/* CAMPOS DE FORMULÁRIO (DATAS, BASES, FILTROS) */
		.biblivre_form_body.reports .field {
			display: flex !important;
			align-items: center !important;
			margin-bottom: 10px !important;
			gap: 12px !important;
			flex-wrap: wrap !important;
		}

		.biblivre_form_body.reports .field:last-child {
			margin-bottom: 0 !important;
		}

		.biblivre_form_body.reports .field .label {
			width: 160px !important;
			min-width: 140px !important;
			font-size: 13px !important;
			font-weight: 600 !important;
			color: #475569 !important;
			float: none !important;
		}

		.biblivre_form_body.reports .field .value {
			flex: 1 !important;
			float: none !important;
		}

		.biblivre_form_body.reports input[type="text"],
		.biblivre_form_body.reports select {
			height: 34px !important;
			border-radius: 6px !important;
			border: 1px solid #cbd5e1 !important;
			padding: 0 10px !important;
			font-size: 13px !important;
			font-family: inherit !important;
			color: #0f172a !important;
			background: #ffffff !important;
			outline: none !important;
			box-sizing: border-box !important;
			width: 100% !important;
			max-width: 320px !important;
			transition: border-color 0.2s, box-shadow 0.2s !important;
		}

		.biblivre_form_body.reports input[type="text"]:focus,
		.biblivre_form_body.reports select:focus {
			border-color: #2563eb !important;
			box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15) !important;
		}

		.description {
			font-size: 12px !important;
			color: #64748b !important;
			margin-bottom: 12px !important;
			line-height: 1.5 !important;
		}

		/* CAIXAS DE PESQUISA (AUTOR, CATALOGAÇÃO, USUÁRIO) */
		.search_box {
			background: #f8fafc !important;
			border: 1px solid #e2e8f0 !important;
			border-radius: 8px !important;
			padding: 10px 14px !important;
			margin-top: 10px !important;
			margin-bottom: 10px !important;
		}

		.simple_search {
			display: flex !important;
			align-items: center !important;
			gap: 8px !important;
			flex-wrap: wrap !important;
		}

		.simple_search .query {
			flex: 1 !important;
			min-width: 220px !important;
			float: none !important;
		}

		#authorDiv .search_box .simple_search .query .small_input,
		#userDiv .search_box .simple_search .query .small_input,
		#catalogingDiv .search_box .simple_search .query .small_input {
			width: 100% !important;
			max-width: 100% !important;
			margin-left: 0 !important;
			height: 34px !important;
			border-radius: 6px !important;
			border: 1px solid #cbd5e1 !important;
			padding: 0 12px !important;
			font-size: 13px !important;
			outline: none !important;
			box-sizing: border-box !important;
		}

		.simple_search .buttons {
			display: flex !important;
			align-items: center !important;
			float: none !important;
			margin: 0 !important;
		}

		/* BOTÃO PRIMÁRIO ESCURO / MODERNO */
		.main_button {
			background: #0f172a !important;
			color: #ffffff !important;
			border: none !important;
			border-radius: 6px !important;
			height: 34px !important;
			padding: 0 16px !important;
			font-size: 12px !important;
			font-weight: 700 !important;
			cursor: pointer !important;
			display: inline-flex !important;
			align-items: center !important;
			justify-content: center !important;
			text-decoration: none !important;
			transition: background 0.2s ease !important;
			white-space: nowrap !important;
		}

		.main_button:hover {
			background: #1e293b !important;
			color: #ffffff !important;
		}

		/* CARDS DE RESULTADO */
		.search_results .result {
			background: #ffffff !important;
			border: 1px solid #e2e8f0 !important;
			border-radius: 8px !important;
			padding: 10px 14px !important;
			margin-bottom: 8px !important;
			display: flex !important;
			align-items: center !important;
			justify-content: space-between !important;
			gap: 12px !important;
			box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04) !important;
		}

		.record_author, .record_user, .record_cataloging {
			border-left: 4px solid #2563eb !important;
			border-bottom: none !important;
			background: #f8fafc !important;
			border-radius: 0 6px 6px 0 !important;
			margin: 0 !important;
			padding: 8px 12px !important;
			font-size: 13px !important;
			line-height: 1.5 !important;
			flex: 1 !important;
		}

		.record_author label, .record_user label, .record_cataloging label {
			font-weight: 700 !important;
			color: #0f172a !important;
		}

		.search_results .result .buttons a.button {
			background: #ffffff !important;
			border: 1px solid #cbd5e1 !important;
			border-radius: 6px !important;
			padding: 6px 12px !important;
			font-size: 12px !important;
			font-weight: 700 !important;
			color: #1e293b !important;
			text-decoration: none !important;
			display: inline-block !important;
			transition: all 0.2s !important;
			white-space: nowrap !important;
		}

		.search_results .result .buttons a.button:hover {
			background: #eff6ff !important;
			border-color: #3b82f6 !important;
			color: #1d4ed8 !important;
		}

		/* BARRA DE NAVEGAÇÃO / PAGINAÇÃO */
		.paging_bar {
			display: flex !important;
			align-items: center !important;
			gap: 4px !important;
			margin: 8px 0 !important;
		}

		.paging_bar a, .paging_bar span.page {
			background: #ffffff !important;
			border: 1px solid #cbd5e1 !important;
			border-radius: 5px !important;
			padding: 3px 9px !important;
			font-size: 12px !important;
			font-weight: 600 !important;
			color: #334155 !important;
			text-decoration: none !important;
		}

		.paging_bar span.page.selected {
			background: #0f172a !important;
			color: #ffffff !important;
			border-color: #0f172a !important;
		}

		/* BARRA DE ORDENAÇÃO DE CATALOGAÇÃO */
		.search_ordering_bar {
			background: #f8fafc !important;
			border: 1px solid #e2e8f0 !important;
			border-radius: 6px !important;
			padding: 8px 12px !important;
			margin-bottom: 8px !important;
			display: flex !important;
			align-items: center !important;
			justify-content: space-between !important;
			flex-wrap: wrap !important;
			gap: 8px !important;
		}

		/* BOTÃO FINAL "GERAR RELATÓRIO" */
		#buttonDiv {
			border: none !important;
			background: transparent !important;
			box-shadow: none !important;
			padding: 12px 0 24px 0 !important;
			margin-bottom: 24px !important;
		}

		#buttonDiv .biblivre_form_body .buttons {
			display: flex !important;
			justify-content: center !important;
			align-items: center !important;
			text-align: center !important;
			float: none !important;
		}

		#buttonDiv .main_button {
			background: linear-gradient(135deg, #1d4ed8 0%, #2563eb 100%) !important;
			color: #ffffff !important;
			height: 42px !important;
			padding: 0 28px !important;
			font-size: 14px !important;
			font-weight: 800 !important;
			border-radius: 8px !important;
			box-shadow: 0 4px 14px rgba(37, 99, 235, 0.28) !important;
			cursor: pointer !important;
			display: inline-flex !important;
			align-items: center !important;
			justify-content: center !important;
			text-decoration: none !important;
			transition: transform 0.15s ease, box-shadow 0.15s ease !important;
		}

		#buttonDiv .main_button:hover {
			transform: translateY(-1px) !important;
			box-shadow: 0 6px 20px rgba(37, 99, 235, 0.35) !important;
		}
	</style>
</layout:head>

<layout:body>
	<div class="page_help"><i18n:text key="administration.reports.page_help" /></div>
	
	<fieldset id="biblivre_reports_form" class="block reports">
		<legend><i18n:text key="administration.reports.title" /></legend>
		
		<div id="reportSelection" class="reports center">
			<div class="title"><i18n:text key="administration.reports.select_report" /></div>
			<div class="ncspacer"></div>
			<div class="ncspacer"></div>
			<select name="report" id="reportSelect" onchange="Reports.toggleDivs(this.value)" >
			
				<option value=""><i18n:text key="administration.reports.select.option.default"/></option>
				
				<optgroup label="<i18n:text key="administration.reports.select.group.acquisition"/>">
					<option value="1"><i18n:text key="administration.reports.select.option.acquisition"/></option>
				</optgroup>
				
				<optgroup label="<i18n:text key="administration.reports.select.group.cataloging"/>">
					<option value="2"><i18n:text key="administration.reports.select.option.summary"/></option>
					<option value="3"><i18n:text key="administration.reports.select.option.dewey"/></option>
					<option value="4"><i18n:text key="administration.reports.select.option.records"/></option>
					<option value="5"><i18n:text key="administration.reports.select.option.bibliography"/></option>
					<option value="13"><i18n:text key="administration.reports.select.option.accession_number"/></option>
					<option value="14"><i18n:text key="administration.reports.select.option.accession_number.full"/></option>
					<option value="15"><i18n:text key="administration.reports.select.option.topographic"/></option>
					<option value="16"><i18n:text key="administration.reports.select.option.holdings"/></option>
				</optgroup>
				
				<optgroup label="<i18n:text key="administration.reports.select.group.circulation"/>">
					<option value="6"><i18n:text key="administration.reports.select.option.user"/></option>
					<option value="7"><i18n:text key="administration.reports.select.option.all_users"/></option>
					<option value="8"><i18n:text key="administration.reports.select.option.late_lendings"/></option>
					<option value="12"><i18n:text key="administration.reports.select.option.reservations"/></option>
					<option value="9"><i18n:text key="administration.reports.select.option.searches"/></option>
					<option value="10"><i18n:text key="administration.reports.select.option.lendings"/></option>
				</optgroup>
				
				<optgroup label="<i18n:text key="administration.reports.select.group.custom"/>">
					<option value="17"><i18n:text key="administration.reports.select.option.custom_count"/></option>
				</optgroup>
			</select>
		</div>
	</fieldset>
	
	<fieldset id="dateDiv" class="block reports">
		<legend><i18n:text key="administration.reports.fieldset.dates" /></legend>
		
		<div class="biblivre_form_body reports">
			<div class="field">
				<div class="label"><i18n:text key="administration.reports.field.start_date" /></div>
				<div class="value"><input type="text" name="start" class="datepicker"></div>
				<div class="clear"></div>	
			</div>
			<div class="field">
				<div class="label"><i18n:text key="administration.reports.field.start_date" /></div>
				<div class="value"><input type="text" name="end" class="datepicker"></div>
				<div class="clear"></div>	
			</div>
		</div>
	</fieldset>
	
	<fieldset id="databaseSelection" class="block reports">
		<legend><i18n:text key="administration.reports.fieldset.database" /></legend>
		
		<div class="biblivre_form_body reports">
			<div class="field">
				<div class="label"><i18n:text key="administration.reports.field.database" /></div>
				<div class="value" id="database_selection_combo">
					<select name="database">
						<option value="<%=RecordDatabase.MAIN%>"><i18n:text key="administration.reports.option.database.main"/></option>
						<option value="<%=RecordDatabase.WORK%>"><i18n:text key="administration.reports.option.database.work"/></option>
					</select>
				</div>
				<div class="clear"></div>	
			</div>
		</div>
	</fieldset>
	
	<fieldset id="orderDiv" class="block reports">
		<legend><i18n:text key="administration.reports.fieldset.order" /></legend>
		
		<div class="biblivre_form_body reports">
			<div class="field">
				<div class="label"><i18n:text key="administration.reports.field.order" /></div>
				<div class="value">
					<select name="order">
						<option value="1"><i18n:text key="administration.reports.option.classification"/></option>
						<option value="2"><i18n:text key="administration.reports.option.title"/></option>
						<option value="3"><i18n:text key="administration.reports.option.author"/></option>
					</select>
				</div>
				<div class="clear"></div>	
			</div>
		</div>
	</fieldset>
	
	<fieldset id="deweyDiv" class="block reports">
		<legend><i18n:text key="administration.reports.fieldset.dewey" /></legend>
		
		<div class="biblivre_form_body reports">
			<div class="field">
				<div class="label"><i18n:text key="administration.reports.field.datafield" /></div>
				<div class="value">
					<select name="datafield">
						<option value="082">082 |a (<i18n:text key="administration.reports.option.dewey" />)</option>
						<option value="090">090 |a (<i18n:text key="administration.reports.option.location"/>)</option>
					</select>
				</div>
				<div class="clear"></div>	
			</div>
			<div class="field">
				<div class="label"><i18n:text key="administration.reports.field.digits" /></div>
				<div class="value">
					<select name="digits">
						<option value="-1"><i18n:text key="administration.reports.option.all_digits"/></option>
						<option value="1">1 (<i18n:text key="administration.reports.label.example"/> 500)</option>
						<option value="2">2 (<i18n:text key="administration.reports.label.example"/> 560)</option>
						<option value="3">3 (<i18n:text key="administration.reports.label.example"/> 561)</option>
						<option value="4" selected="selected">4 (<i18n:text key="administration.reports.label.example"/> 561.1)</option>
						<option value="5">5 (<i18n:text key="administration.reports.label.example"/> 561.11)</option>
						<option value="6">6 (<i18n:text key="administration.reports.label.example"/> 561.117)</option>
					</select>
				</div>
				<div class="clear"></div>
			</div>
		</div>
	</fieldset>
	
	<fieldset id="authorDiv" class="block reports">
		<legend><i18n:text key="administration.reports.fieldset.author" /></legend>
		
		<div class="selected_highlight"></div>
		<textarea class="selected_highlight_template template"></textarea>
		
		<div class="selected_record tabs">
			<div class="tabs_body">
				<div class="tab_body" data-tab="record">
					<div id="biblivre_record"></div>
					<textarea id="biblivre_record_template" class="template"></textarea>
				</div>
				<div class="tab_body" data-tab="form">
					<div class="biblivre_form_body"></div>
				</div>
				<div class="tab_body" data-tab="marc">
					<div class="biblivre_marc_body"></div>
				</div>
				<div class="tabs_extra_content">
					<div class="tab_extra_content biblivre_form" data-tab="form">
						<div id="biblivre_form"></div>
					</div>
					<div class="tab_extra_content biblivre_marc" data-tab="marc">
						<fieldset>
							<div id="biblivre_marc"></div>
							<textarea id="biblivre_marc_template" class="template"></textarea>
						</fieldset>
					</div>				
				</div>
			</div>
		</div>
	
		<div class="search_box">
			<div class="simple_search submit_on_enter">
				<div class="query">
					<input type="text" name="query" class="small_input auto_focus" placeholder="<i18n:text key="search.user.simple_term_title" />"/>
				</div>
				<div class="buttons">
					<a class="main_button arrow_right" onclick="CatalogingSearch.search('simple');"><i18n:text key="search.common.button.list_all" /></a>
				</div>
			</div>
		</div>
		
		<div class="search_results_area">
			<div class="search_loading_indicator loading_indicator"></div>

			<div class="paging_bar"></div>
			<div class="clear"></div>
		
			<div class="search_results_box">
				<div class="search_results"></div>
				<textarea class="search_results_template template"><!-- 
					{#foreach $T.data as record}
						<div class="result" rel="{$T.record.id}">
							<div class="buttons">
								<a class="button center" rel="open_item" onclick="Reports.generateAuthorReport({#var $T.record});"><i18n:text key="administration.reports.button.generate_report" /></a>
							</div>
							<div class="record_author">
								{#if $T.record.author}<label><i18n:text key="search.bibliographic.author" /></label>: {$T.record.author}<br/>{#/if}
								{#if $T.record.count}<label><i18n:text key="administration.reports.label.author_count" /></label>: {$T.record.count}<br/>{#/if}
							</div>
							<div class="clear"></div>
						</div>
					{#/for}
				--></textarea>
			</div>
	
			<div class="paging_bar"></div>
		</div>
	</fieldset>
	
	<fieldset id="fieldCountDiv" class="block reports">
		<legend><i18n:text key="administration.reports.fieldset.field_count" /></legend>
		<div class="description"><i18n:text key="administration.reports.field_count.description" /></div>
		
		<div class="biblivre_form_body reports">
			<div class="field">
				<div class="label"><i18n:text key="administration.reports.field.marc_field" /></div>
				<div class="value" id="marc_field_combo"></div>
				<div class="clear"></div>	
			</div>
			
			<div class="field">
				<div class="label"><i18n:text key="administration.reports.field.order" /></div>
				<div class="value">
					<select name="count_order">
						<option value="1"><i18n:text key="administration.reports.select.option.marc_field"/></option>
						<option value="2"><i18n:text key="administration.reports.select.option.field_count"/></option>
					</select>
				</div>
				<div class="clear"></div>
			</div>
		</div>
	</fieldset>
	
	<fieldset id="catalogingDiv" class="block reports">
		<legend><i18n:text key="administration.reports.fieldset.cataloging" /></legend>
	
		<div class="selected_highlight"></div>
		<textarea class="selected_highlight_template template"></textarea>
		
		<div class="selected_record tabs">
			<div class="tabs_body">
				<div class="tab_body" data-tab="record">
					<div id="biblivre_record"></div>
					<textarea id="biblivre_record_template" class="template"></textarea>
				</div>
				<div class="tab_body" data-tab="form">
					<div class="biblivre_form_body"></div>
				</div>
				<div class="tab_body" data-tab="marc">
					<div class="biblivre_marc_body"></div>
				</div>
				<div class="tabs_extra_content">
					<div class="tab_extra_content biblivre_form" data-tab="form">
						<div id="biblivre_form"></div>
					</div>
					<div class="tab_extra_content biblivre_marc" data-tab="marc">
						<fieldset>
							<div id="biblivre_marc"></div>
							<textarea id="biblivre_marc_template" class="template"></textarea>
						</fieldset>
					</div>				
				</div>
			</div>
		</div>
	
		<div class="search_box">
			<div class="simple_search submit_on_enter">
				<div class="query">
					<input type="text" name="query" class="small_input auto_focus" placeholder="<i18n:text key="search.user.simple_term_title" />"/>
				</div>
				<div class="buttons">
					<a class="main_button arrow_right" onclick="CatalogingSearch.search('simple');"><i18n:text key="search.common.button.list_all" /></a>
				</div>
			</div>
		</div>
		
		<div class="search_results_area">
			<div class="search_ordering_bar" style="padding: 0px 10px;">
	
				<div class="search_indexing_groups"></div>
				<textarea class="search_indexing_groups_template template"><!--
					{#foreach $T.search.indexing_group_count as group_count}
						{#foreach $T.indexing_groups as group}
							{#if $T.group_count.group_id == $T.group.id}
								{#if $T.group.id == CatalogingSearch.lastPagingParameters.indexing_group}
									<div class="group selected">
										<span class="name">{_('cataloging.bibliographic.indexing_groups.' + ($T.group.id ? $T.group.translation_key : 'total'))}</span>
										<span class="value">({_f($T.group_count.result_count)})</span>
									</div>
								{#else}
									<div class="group">
										<a href="javascript:void(0);" onclick="CatalogingSearch.changeIndexingGroup('{$T.group.id}');">{_('cataloging.bibliographic.indexing_groups.' + ($T.group.id ? $T.group.translation_key : 'total'))}</a>
										<span class="value">({_f($T.group_count.result_count)})</span>
									</div>
								{#/if}
							{#/if}						
						{#/for}
						{#if !$T.group_count$last} <div class="hspacer">|</div> {#/if}
					{#/for}
				--></textarea>
	
				<div class="search_sort_by"></div>
				<textarea class="search_sort_by_template template"><!--
					<i18n:text key="search.common.sort_by" />:
					<select class="combo search_sort_combo combo_auto_size combo_align_right" onchange="CatalogingSearch.changeSort(this.value);">
						{#foreach $T.indexing_groups as group}
							{#if $T.group.sortable}
								<option value="{$T.group.id}"{#if ((CatalogingSearch.lastPagingParameters.sort == $T.group.id) || (!CatalogingSearch.lastPagingParameters.sort && $T.group.default_sort))} selected="selected" {#/if}>{_('cataloging.bibliographic.indexing_groups.' + $T.group.translation_key)}</option>
							{#/if}
						{#/for}
					</select>
				--></textarea>			
				
				<div class="clear"></div>
			</div>
		
			<div class="search_loading_indicator loading_indicator"></div>

			<div class="paging_bar"></div>
			<div class="clear"></div>
		
			<div class="search_results_box">
				<div class="search_results"></div>
				<textarea class="search_results_template template"><!-- 
					{#foreach $T.data as record}
						<div class="result" rel="{$T.record.id}">
							<div class="record_cataloging">
								{#if $T.record.title}<label><i18n:text key="search.bibliographic.title" /></label>: {$T.record.title}<br/>{#/if}
								{#if $T.record.author}<label><i18n:text key="search.bibliographic.author" /></label>: {$T.record.author}<br/>{#/if}
								{#if $T.record.publication_year}<label><i18n:text key="search.bibliographic.publication_year" /></label>: {$T.record.publication_year}<br/>{#/if}
								{#if $T.record.shelf_location}<label><i18n:text key="search.bibliographic.shelf_location" /></label>: {$T.record.shelf_location}<br/>{#/if}
								{#if $T.record.isbn}<label><i18n:text key="search.bibliographic.isbn" /></label>: {$T.record.isbn}<br/>{#/if}
								{#if $T.record.issn}<label><i18n:text key="search.bibliographic.issn" /></label>: {$T.record.issn}<br/>{#/if}
								{#if $T.record.isrc}<label><i18n:text key="search.bibliographic.isrc" /></label>: {$T.record.isrc}<br/>{#/if}
	
								{#if $T.record.subject}
									<label><i18n:text key="search.bibliographic.subject" /></label>: {$T.record.subject}<br/>
								{#/if}
							</div>
							<div class="clear"></div>
						</div>
				--></textarea>
			</div>
	
			<div class="paging_bar"></div>
		</div>
	</fieldset>
	
	<fieldset id="userDiv" class="block reports">
		<legend><i18n:text key="administration.reports.fieldset.user" /></legend>
		
		<div class="selected_highlight"></div>
		<textarea class="selected_highlight_template template"></textarea>
	
		<div class="search_box">
			<div class="simple_search submit_on_enter">
				<div class="query">
					<input type="text" name="query" class="small_input auto_focus" placeholder="<i18n:text key="administration.reports.user.search" />"/>
					<input type="hidden" name="field" value=""/>
				</div>
				<div class="buttons">
					<a class="main_button arrow_right" onclick="CirculationSearch.search('simple');"><i18n:text key="search.common.button.search" /></a>
				</div>
			</div>
		</div>
		
		<div class="search_results_area">
			<div class="search_loading_indicator loading_indicator"></div>
		
			<div class="paging_bar"></div>
			<div class="clear"></div>
		
			<div class="search_results_box">
				<div class="search_results"></div>
				<textarea class="search_results_template template"><!-- 
					{#foreach $T.data as record}
						<div class="result" rel="{$T.record.id}">
							<div class="buttons">
								<a class="button center" rel="open_item" onclick="Reports.generateUserReport('{$T.record.id}');"><i18n:text key="administration.reports.button.generate_report" /></a>
							</div>
							<div class="record_user">
								{#if $T.record.name}<label><i18n:text key="circulation.user_field.name" /></label>: {$T.record.name}<br/>{#/if}
								<label><i18n:text key="circulation.user_field.id" /></label>: {$T.record.enrollment}<br/>
								<label><i18n:text key="circulation.user_field.type" /></label>: {$T.record.type_name}<br/>
								<div class="user_status_{$T.record.status}"><label><i18n:text key="circulation.user_field.status" /></label>: {_('circulation.user_status.' + $T.record.status)}</div>
							</div>
							<div class="clear"></div>
						</div>
					{#/for}
				--></textarea>
			</div>
			
			<div class="paging_bar"></div>	
		</div>
	</fieldset>
	
	<fieldset id="buttonDiv" class="block reports">
		<div class="biblivre_form_body">
			<div class="buttons">
				<a class="button main_button" onclick="Reports.generateReport();"><i18n:text key="administration.reports.button.generate_report" /></a>
			</div>
			<div class="clear"></div>
		</div>
	</fieldset>
<script type="text/javascript" src="static/scripts/menu-inicio.js"></script>
</layout:body>
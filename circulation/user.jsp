<%@page import="biblivre.core.configurations.Configurations"%>
<%@page import="biblivre.circulation.user.UserStatus"%>
<%@page import="java.util.List"%>
<%@page import="biblivre.administration.usertype.UserTypeBO"%>
<%@page import="biblivre.administration.usertype.UserTypeDTO"%>
<%@ page import="biblivre.core.utils.Constants" %>
<%@ page import="biblivre.circulation.user.UserFields" %>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="layout" uri="/WEB-INF/tlds/layout.tld" %>
<%@ taglib prefix="i18n" uri="/WEB-INF/tlds/translations.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<layout:head>
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.search.css" />
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.circulation.css" />	
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

	<script type="text/javascript" src="static/scripts/biblivre.search.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.circulation.search.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.input.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.circulation.input.js"></script>
	<script type="text/javascript" src="static/scripts/<%= UserFields.getFields((String) request.getAttribute("schema")).getCacheFileName() %>"></script>
	
	<script type="text/javascript" src="static/scripts/zebra_datepicker.js"></script>
	<link rel="stylesheet" type="text/css" href="static/styles/zebra.bootstrap.css">

	<script type="text/javascript" src="static/scripts/jquery.imgareaselect.js"></script>

	<style type="text/css">
		/* =================================================================
		   PADRONIZAÇÃO ULTRA-COMPACTA DARK (CADASTRO E GESTÃO DE USUÁRIOS)
		   ================================================================= */
		body, #circulation_user {
			font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif !important;
			color: #0f172a;
		}

		/* LARGURA CONTROLADA (SEM ALONGAR NA TELA) */
		#circulation_user {
			max-width: 960px !important;
			margin: 0 auto !important;
			padding: 0 8px !important;
			box-sizing: border-box !important;
		}

		/* ZERA ESPAÇADORES VERTICAIS */
		.ncspacer {
			display: none !important;
			height: 0 !important;
			margin: 0 !important;
		}

		/* AJUDA SUPERIOR COMPACTA */
		.page_help {
			background: #f8fafc !important;
			border: 1px solid #e2e8f0 !important;
			border-radius: 6px !important;
			color: #64748b !important;
			font-size: 11px !important;
			padding: 5px 10px !important;
			margin-bottom: 8px !important;
			line-height: 1.2 !important;
		}

		/* CABEÇALHO ESCURO COM BOTÃO NOVO USUÁRIO */
		.page_title {
			background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%) !important;
			border-radius: 8px !important;
			padding: 8px 14px !important;
			margin-bottom: 4px !important;
			display: flex !important;
			align-items: center !important;
			justify-content: space-between !important;
			border: none !important;
		}
		.page_title .image {
			width: 24px !important;
			height: 24px !important;
			background: rgba(255, 255, 255, 0.12) !important;
			border-radius: 5px !important;
			display: flex !important;
			align-items: center !important;
			justify-content: center !important;
			float: none !important;
			margin-right: 8px !important;
		}
		.page_title .image img {
			width: 13px !important;
			height: 13px !important;
			filter: brightness(0) invert(1) !important;
		}
		.page_title .text {
			font-size: 13px !important;
			font-weight: 800 !important;
			color: #ffffff !important;
			float: none !important;
			margin: 0 !important;
			padding: 0 !important;
			flex: 1 !important;
		}
		.page_title .subtext {
			font-size: 10px !important;
			font-weight: normal !important;
			color: #cbd5e1 !important;
			margin-top: 2px !important;
		}
		.page_title .subtext a {
			color: #93c5fd !important;
			font-weight: 700 !important;
			text-decoration: underline !important;
		}
		.page_title .buttons {
			float: none !important;
			margin: 0 !important;
		}

		/* BOTÃO NOVO USUÁRIO */
		.new_record_button {
			background: #10b981 !important;
			color: #ffffff !important;
			border: none !important;
			border-radius: 6px !important;
			height: 28px !important;
			padding: 0 12px !important;
			font-size: 11px !important;
			font-weight: 800 !important;
			display: inline-flex !important;
			align-items: center !important;
			cursor: pointer !important;
			transition: background 0.2s ease !important;
			white-space: nowrap !important;
		}
		.new_record_button:hover {
			background: #059669 !important;
			color: #ffffff !important;
		}

		/* BARRA DE NAVEGAÇÃO */
		.page_navigation {
			margin: 4px 0 !important;
			padding: 0 !important;
		}
		.page_navigation .fright {
			display: inline-flex !important;
			align-items: center !important;
			gap: 4px !important;
		}
		.page_navigation a.button, .paging_bar a {
			background: #ffffff !important;
			border: 1px solid #cbd5e1 !important;
			color: #334155 !important;
			border-radius: 5px !important;
			padding: 3px 8px !important;
			font-size: 11px !important;
			font-weight: 700 !important;
			text-decoration: none !important;
		}
		.paging_bar {
			margin: 4px 0 !important;
		}
		.paging_bar span.page.selected {
			background: #0f172a !important;
			color: #ffffff !important;
			border-radius: 5px !important;
			padding: 2px 7px !important;
			font-size: 11px !important;
			font-weight: 800 !important;
		}

		/* CAIXA DE PESQUISA COMPACTA */
		.search_box {
			background: #ffffff !important;
			border: 1px solid #e2e8f0 !important;
			border-radius: 8px !important;
			padding: 8px 12px !important;
			box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03) !important;
			margin-top: 4px !important;
			margin-bottom: 6px !important;
		}
		.simple_search {
			display: flex !important;
			align-items: center !important;
			flex-wrap: wrap !important;
			gap: 8px !important;
		}
		.simple_search .query {
			flex: 1 !important;
			min-width: 180px !important;
			float: none !important;
		}
		.simple_search .buttons {
			display: flex !important;
			align-items: center !important;
			gap: 6px !important;
			float: none !important;
			margin: 0 !important;
			padding: 0 !important;
			border: none !important;
			background: transparent !important;
			box-shadow: none !important;
		}
		.search_label {
			font-size: 11px !important;
			font-weight: 600 !important;
			color: #64748b !important;
		}

		/* INPUTS E COMBO */
		input[type="text"].big_input {
			height: 30px !important;
			border-radius: 5px !important;
			border: 1px solid #cbd5e1 !important;
			padding: 0 10px !important;
			font-size: 12px !important;
			font-family: inherit !important;
			color: #0f172a !important;
			outline: none !important;
			box-sizing: border-box !important;
			width: 100% !important;
		}
		input[type="text"].big_input:focus {
			border-color: #0f172a !important;
			box-shadow: 0 0 0 2px rgba(15, 23, 42, 0.1) !important;
		}
		select.combo {
			height: 30px !important;
			border-radius: 5px !important;
			border: 1px solid #cbd5e1 !important;
			padding: 0 6px !important;
			font-size: 11px !important;
			font-weight: 600 !important;
			color: #0f172a !important;
			background: #ffffff !important;
			outline: none !important;
		}

		/* BOTÃO LISTAR TODOS / PESQUISAR ESCURO */
		.main_button {
			background: #0f172a !important;
			color: #ffffff !important;
			border: none !important;
			border-radius: 5px !important;
			height: 30px !important;
			padding: 0 12px !important;
			font-size: 11px !important;
			font-weight: 700 !important;
			cursor: pointer !important;
			display: inline-flex !important;
			align-items: center !important;
			justify-content: center !important;
			transition: background 0.2s ease !important;
			white-space: nowrap !important;
		}
		.main_button:hover {
			background: #1e293b !important;
			color: #ffffff !important;
		}

		/* CARDS DE RESULTADOS */
		.search_results_area {
			margin-top: 4px !important;
		}
		.search_results_box {
			background: transparent !important;
			border: none !important;
		}
		.search_results .result {
			background: #ffffff !important;
			border: 1px solid #e2e8f0 !important;
			border-radius: 6px !important;
			padding: 6px 12px !important;
			margin-bottom: 5px !important;
			display: flex !important;
			align-items: center !important;
			justify-content: space-between !important;
			gap: 10px !important;
		}
		.search_results .result .record {
			flex: 1 !important;
			font-size: 11px !important;
			line-height: 1.3 !important;
			color: #334155 !important;
		}
		.search_results .result .record label {
			font-weight: 700 !important;
			color: #0f172a !important;
			display: inline-block !important;
			min-width: 85px !important;
		}

		/* ZERA ÁREA DOS BOTÕES (SEM BALÃO VERDE) */
		.search_results .result .buttons {
			background: transparent !important;
			border: none !important;
			padding: 0 !important;
			margin: 0 !important;
			box-shadow: none !important;
			display: flex !important;
			align-items: center !important;
			gap: 6px !important;
			flex-shrink: 0 !important;
		}

		/* BOTÕES ABRIR E BLOQUEAR */
		.search_results .result .buttons a.button {
			border-radius: 5px !important;
			height: 26px !important;
			padding: 0 10px !important;
			font-size: 11px !important;
			font-weight: 700 !important;
			cursor: pointer !important;
			text-decoration: none !important;
			display: inline-flex !important;
			align-items: center !important;
			white-space: nowrap !important;
			border: none !important;
		}
		a[rel="open_item"] {
			background: #0f172a !important;
			color: #ffffff !important;
		}
		a[rel="open_item"]:hover {
			background: #1e293b !important;
		}
		a[rel="block_user"] {
			background: #fef2f2 !important;
			color: #dc2626 !important;
			border: 1px solid #fecaca !important;
		}
		a[rel="block_user"]:hover {
			background: #dc2626 !important;
			color: #ffffff !important;
		}
		a[rel="unblock_user"] {
			background: #ecfdf5 !important;
			color: #059669 !important;
			border: 1px solid #a7f3d0 !important;
		}

		/* STATUS COMPACTO */
		.record div[class*="user_status_"] {
			display: inline-flex !important;
			align-items: center !important;
			font-size: 10px !important;
			font-weight: 700 !important;
			padding: 1px 5px !important;
			border-radius: 3px !important;
		}
		.record .user_status_active, .record .user_status_0 {
			background: #ecfdf5 !important;
			color: #059669 !important;
			border: 1px solid #a7f3d0 !important;
		}
		.record .user_status_blocked, .record .user_status_1 {
			background: #fef2f2 !important;
			color: #dc2626 !important;
			border: 1px solid #fecaca !important;
		}

		/* ABAS (TABS) COMPACTAS E MODERNAS */
		.tabs_head {
			display: flex !important;
			gap: 4px !important;
			border-bottom: 2px solid #e2e8f0 !important;
			margin: 8px 0 !important;
			padding: 0 !important;
			list-style: none !important;
		}
		.tabs_head li.tab {
			padding: 6px 14px !important;
			font-size: 12px !important;
			font-weight: 700 !important;
			color: #64748b !important;
			border-radius: 6px 6px 0 0 !important;
			cursor: pointer !important;
			background: #f1f5f9 !important;
			transition: all 0.2s ease !important;
		}
		.tabs_head li.tab:hover {
			color: #0f172a !important;
			background: #e2e8f0 !important;
		}
		.tabs_head li.tab.selected {
			background: #0f172a !important;
			color: #ffffff !important;
		}

		/* CARTÃO DO LEITOR SELECIONADO COMPACTO */
		.selected_highlight {
			background: #ffffff !important;
			border: 1px solid #cbd5e1 !important;
			border-radius: 8px !important;
			padding: 10px 14px !important;
			margin-bottom: 8px !important;
			display: flex !important;
			align-items: center !important;
			gap: 12px !important;
		}
		.selected_highlight .user_photo {
			width: 65px !important;
			height: 65px !important;
			border-radius: 6px !important;
			border: 1px solid #e2e8f0 !important;
			object-fit: cover !important;
			margin: 0 !important;
		}
		.selected_highlight .record {
			flex: 1 !important;
			font-size: 11px !important;
			line-height: 1.35 !important;
		}
		.selected_highlight .buttons.photo_buttons {
			display: flex !important;
			flex-direction: column !important;
			gap: 4px !important;
			background: transparent !important;
			border: none !important;
			padding: 0 !important;
			margin: 0 !important;
		}
		.selected_highlight .buttons a.button, .selected_highlight .buttons a.danger_button {
			border-radius: 4px !important;
			padding: 4px 10px !important;
			font-size: 10px !important;
			font-weight: 700 !important;
			text-align: center !important;
		}

		/* FORMULÁRIO DE CADASTRO/EDIÇÃO */
		.tab_body.biblivre_form_body {
			background: #ffffff !important;
			border: 1px solid #e2e8f0 !important;
			border-radius: 8px !important;
			padding: 12px !important;
			margin-bottom: 8px !important;
		}
		.field {
			margin-bottom: 8px !important;
			display: flex !important;
			align-items: center !important;
		}
		.field .label {
			width: 140px !important;
			font-size: 11px !important;
			font-weight: 700 !important;
			color: #0f172a !important;
		}
		.field .value {
			flex: 1 !important;
		}
		.field .value input[type="text"], .field .value select {
			height: 28px !important;
			border-radius: 4px !important;
			border: 1px solid #cbd5e1 !important;
			padding: 0 8px !important;
			font-size: 11px !important;
			outline: none !important;
			width: 100% !important;
			max-width: 380px !important;
			box-sizing: border-box !important;
		}

		/* BOTÕES DO RODAPÉ (SALVAR / CANCELAR) */
		.footer_buttons {
			margin-top: 8px !important;
			display: flex !important;
			gap: 6px !important;
		}
		.footer_buttons a.button, .footer_buttons a.main_button {
			border-radius: 5px !important;
			height: 28px !important;
			padding: 0 12px !important;
			font-size: 11px !important;
			font-weight: 700 !important;
			display: inline-flex !important;
			align-items: center !important;
		}

		/* POPUP */
		.popup {
			background: #ffffff !important;
			border: 1px solid #cbd5e1 !important;
			border-radius: 8px !important;
			box-shadow: 0 10px 24px rgba(15, 23, 42, 0.2) !important;
			padding: 14px !important;
		}
	</style>

	<script type="text/javascript">
		var CirculationSearch = CreateSearch(CirculationSearchClass, {
			type: 'circulation.user',
			prefix: 'circulation.user',
			root: '#circulation_user'
		});

		CirculationInput.type = 'circulation.user';
		CirculationInput.root = '#circulation_user';
		CirculationInput.search = CirculationSearch;

		$(document).ready(function() {
			var global = Globalize.culture().calendars.standard;

			$('#search_box input.datepicker').Zebra_DatePicker({
				days: global.days.names,
				days_abbr: global.days.namesAbbr,
				months: global.months.names,
				months_abbr: global.months.namesAbbr,
				format: Core.convertDateFormat(global.patterns.d),
				show_select_today: _('common.today'),
				lang_clear_date: _('common.clear'),
				direction: false,
				offset: [-19, -7],
				readonly_element: false
			});
		});
	</script>
</layout:head>

<%
	List<UserTypeDTO> userTypes = UserTypeBO.getInstance((String) request.getAttribute("schema")).list();
%>

<layout:body>
	<div class="page_help"><i18n:text key="circulation.user.page_help" /></div>

	<div id="circulation_user">
		<c:set var="user_field_prefix" value="<%= Constants.TRANSLATION_USER_FIELD %>" scope="page" />
			
		<div class="page_title">
			<div class="image"><img src="static/images/titles/search.png" /></div>
	
			<div class="simple_search text contains_subtext">
				<i18n:text key="search.common.simple_search" />
				<div class="subtext"><i18n:text key="search.common.switch_to" /> <a href="#search=advanced"><i18n:text key="search.common.advanced_search" /></a></div>
			</div>
	
			<div class="advanced_search text contains_subtext">
				<i18n:text key="search.common.advanced_search" />
				<div class="subtext"><i18n:text key="search.common.switch_to" /> <a href="#search=simple"><i18n:text key="search.common.simple_search" /></a></div>
			</div>

			<div class="buttons">
				<a class="button center new_record_button" onclick="CirculationInput.newRecord();">➕ <i18n:text key="circulation.user.button.new" /></a>
			</div>
			
			<div class="clear"></div>
		</div>
		
		<div class="page_navigation">
			<a href="javascript:void(0);" class="button paging_button back_to_search" onclick="CirculationSearch.closeResult();"><i18n:text key="search.common.back_to_search" /></a>

			<div class="fright">
				<a href="javascript:void(0);" class="button paging_button paging_button_prev" onclick="CirculationSearch.previousResult();">‹ <i18n:text key="search.common.previous" /></a>
				<span class="search_count"></span>
				<a href="javascript:void(0);" class="button paging_button paging_button_next" onclick="CirculationSearch.nextResult();"><i18n:text key="search.common.next" /> ›</a>
			</div>

			<div class="clear"></div>
		</div>
	
		<div class="selected_highlight"></div>
		<textarea class="selected_highlight_template template"><!-- 
			<div class="buttons photo_buttons user_status_{$T.status}">
				<div class="view">
					<a class="button center" onclick="CirculationInput.editRecord('{$T.id}');"><i18n:text key="common.edit" /></a>
					<a class="danger_button center delete" onclick="CirculationInput.deleteRecord('{$T.id}');"><i18n:text key="common.delete" /></a>
					<a class="danger_button center inactive" onclick="CirculationInput.deleteRecord('{$T.id}');"><i18n:text key="circulation.user.button.inactive" /></a>
				</div>
	
				<div class="edit">
					<a class="main_button center" onclick="CirculationInput.saveRecord();"><i18n:text key="common.save" /></a>
					<a class="button center" onclick="CirculationInput.saveRecord(true);"><i18n:text key="common.save_as_new" /></a>
					<a class="button center" onclick="CirculationInput.cancelEdit();"><i18n:text key="common.cancel" /></a>
				</div>
				
				<div class="new">
					<a class="main_button center" onclick="CirculationInput.saveRecord();"><i18n:text key="common.save" /></a>
					<a class="button center" onclick="CirculationInput.cancelEdit();"><i18n:text key="common.cancel" /></a>
				</div>
			</div>
			{#if $T.photo_id}
				<img class="user_photo" src="DigitalMediaController/?id={$T.photo_id}"/>
			{#else}
				<img class="user_photo" src="static/images/photo.png"/>
			{#/if}
			<div class="record">
				{#if $T.name}<label><i18n:text key="circulation.user_field.name" /></label>: <strong>{$T.name}</strong><br/>{#/if}
				<label><i18n:text key="circulation.user_field.id" /></label>: {$T.enrollment}<br/>
				{#if $T.type}<label><i18n:text key="circulation.user_field.type" /></label>: {$T.type_name}<br/>{#/if}
				<div class="user_status_{$T.status}"><label><i18n:text key="circulation.user_field.status" /></label>: {_('circulation.user_status.' + $T.status)}</div>
	
				<div class="ncspacer"></div>				
				{#if $T.created}<label><i18n:text key="common.created" /></label>: {_d($T.created, 'd t')}{#/if} 
				{#if $T.modified && $T.modified != $T.created}<br/><label><i18n:text key="common.modified" /></label>: {_d($T.modified, 'd t')}{#/if}
			</div>
		--></textarea>
	
		<div class="selected_record tabs">
			<ul class="tabs_head">
				<li class="tab" data-tab="form" onclick="Core.changeTab(this, CirculationSearch);"><i18n:text key="circulation.user.tabs.form" /></li>
				<li class="tab" data-tab="lendings" onclick="Core.changeTab(this, CirculationSearch);"><i18n:text key="circulation.user.tabs.lendings" /></li>
				<li class="tab" data-tab="reservations" onclick="Core.changeTab(this, CirculationSearch);"><i18n:text key="circulation.user.tabs.reservations" /></li>
				<li class="tab" data-tab="fines" onclick="Core.changeTab(this, CirculationSearch);"><i18n:text key="circulation.user.tabs.fines" /></li>
			</ul>
	
			<div class="tabs_body">
				<div class="tab_body biblivre_form_body" data-tab="form">
					<div id="biblivre_circulation_form_body"></div>
					<textarea id="biblivre_circulation_form_body_template" class="template"><!-- 
						<input type="hidden" name="id" value="{$T.id}"/>
	
						<div class="field">
							<div class="label"><i18n:text key="circulation.user_field.name" /></div>
							<div class="value"><input type="text" name="name" maxlength="512" value="{$.trim($T.name)}"></div>
							<div class="clear"></div>	
						</div>
	
						<div class="field">
							<div class="label"><i18n:text key="circulation.user_field.id" /></div>
							<div class="value"><div class="text"><strong>{$T.enrollment}</strong></div></div>
							<div class="clear"></div>	
						</div>
	
						<div class="field">
							<div class="label"><i18n:text key="circulation.user_field.type" /></div>
							<div class="value">
								<select name="type">
									<c:forEach var="userType" items="<%= userTypes %>" >
										<option value="${userType.id}" {#if $T.type == '${userType.id}'}selected{#/if}>${userType.name}</option>
									</c:forEach>
								</select>						
							</div>
							<div class="clear"></div>	
						</div>

						<div class="field">
							<div class="label"><i18n:text key="circulation.user_field.status" /></div>
							<div class="value">
								<select name="status">
									<c:forEach var="status" items="<%= UserStatus.values() %>" >
										<option value="${status.string}" {#if $T.status == '${status.string}'}selected{#/if}><i18n:text key="circulation.user_status.${status.string}" /></option>
									</c:forEach>					
								</select>						
							</div>
							<div class="clear"></div>	
						</div>
						
						<div class="field photo_field">
							<div class="label"><i18n:text key="circulation.user_field.photo" /></div>
							<div>
								<input type="file" />
								<input type="hidden" name="photo_id" value="{$T.photo_id}">
							</div>
							<div class="clear"></div>	
						</div>
					--></textarea>
				</div>
				
				<div class="tab_body" data-tab="lendings">
					<div id="biblivre_circulation_lendings"></div>
					<textarea id="biblivre_circulation_lendings_template" class="template"><!-- 
						{#if $T.data && $T.data.length > 0}
							{#foreach $T.data as info}
								<div class="result user_lending {#if $T.info.lending.returnDate}user_lending_returned_lending{#else}user_lending_active_lending{#/if}" rel="{$T.info.lending.id}">
									<div class="record">
										{#if $T.info.biblio.title}<label><i18n:text key="search.bibliographic.title" /></label>: <strong>{$T.info.biblio.title}</strong><br/>{#/if}
										{#if $T.info.biblio.author}<label><i18n:text key="search.bibliographic.author" /></label>: {$T.info.biblio.author}<br/>{#/if}
										{#if $T.info.biblio.publication_year}<label><i18n:text key="search.bibliographic.publication_year" /></label>: {$T.info.biblio.publication_year}<br/>{#/if}
										{#if $T.info.biblio.shelf_location || $T.info.holding.location_d}
											<label><i18n:text key="search.bibliographic.shelf_location" /></label>: {$T.info.biblio.shelf_location || ''} {$T.info.holding.location_d || ''}<br/>
										{#/if}
										{#if $T.info.biblio.isbn}<label><i18n:text key="search.bibliographic.isbn" /></label>: {$T.info.biblio.isbn}<br/>{#/if}
		
										<div class="ncspacer"></div>						
		
										<label><i18n:text key="search.holding.accession_number" /></label>: <strong>{$T.info.holding.accession_number}</strong><br/>
										<label><i18n:text key="circulation.lending.lending_date" /></label>: {_d($T.info.lending.created,'f')}<br/>
										{#if $T.info.lending.returnDate}
											<label><i18n:text key="circulation.lending.return_date" /></label>: {_d($T.info.lending.returnDate, 'f')}<br/>
										{#else}
											<label><i18n:text key="circulation.lending.expected_return_date" /></label>: <strong>{_d($T.info.lending.expectedReturnDate, 'D')}</strong><br/>

											{#if $T.info.lending.daysLate > 0}
												<div class="ncspacer"></div>
												<label><i18n:text key="circulation.lending.days_late" /></label>: <span class="value_error">{ _f($T.info.lending.daysLate || 0) } dias</span><br/>
												<label><i18n:text key="circulation.lending.estimated_fine" /></label>: <span class="value_error"><%= Configurations.getString((String) request.getAttribute("schema"), Constants.CONFIG_CURRENCY) %> {_f($T.info.lending.estimatedFine || 0, 'n2') }</span><br/>
											{#/if}
										{#/if}		
									</div>
									<div class="lending_buttons">
										{#if $T.info.lending.returnDate}
											<a class="button center" onclick="CirculationSearch.printReceipt('{$T.info.lending.id}');"><i18n:text key="circulation.lending.button.print_return_receipt" /></a>
										{#else}
											<a class="button center" onclick="CirculationSearch.printReceipt('{$T.info.lending.id}');"><i18n:text key="circulation.lending.button.print_lending_receipt" /></a>
										{#/if}		
									</div>
									<div class="clear"></div>
								</div>
							{#/for}
						{#else}
							<p style="padding: 10px; color: #64748b; font-size: 11px;"><i18n:text key="circulation.user.no_lendings" /></p>
						{#/if}
					--></textarea>
				</div>
				<div class="clear"></div>
				
				<div class="tab_body" data-tab="reservations">
					<div id="biblivre_circulation_reservations"></div>
					<textarea id="biblivre_circulation_reservations_template" class="template"><!-- 
						{#if $T.data[0].reservationInfoList && $T.data[0].reservationInfoList.length > 0}
							{#foreach $T.data[0].reservationInfoList as info}
								<div class="result user_reservation" rel="{$T.info.id}">
									<div class="record">
										{#if $T.info.biblio.title}<label><i18n:text key="search.bibliographic.title" /></label>: <strong>{$T.info.biblio.title}</strong><br/>{#/if}
										{#if $T.info.biblio.author}<label><i18n:text key="search.bibliographic.author" /></label>: {$T.info.biblio.author}<br/>{#/if}
										<label><i18n:text key="circulation.reservation.reserve_date" /></label>: {_d($T.info.reservation.created, 'f')}<br/>
										<label><i18n:text key="circulation.reservation.expiration_date" /></label>: {_d($T.info.reservation.expires, 'D')}<br/>
									</div>
									<div class="clear"></div>
								</div>
							{#/for}
						{#else}
							<p style="padding: 10px; color: #64748b; font-size: 11px;"><i18n:text key="circulation.user.no_reserves" /></p>
						{#/if}
					--></textarea>
				</div>
				<div class="clear"></div>
				
				<div class="tab_body" data-tab="fines">
					<div id="biblivre_circulation_fines"></div>
					<textarea id="biblivre_circulation_fines_template" class="template"><!-- 
						{#if $T.data && $T.data.length > 0}
							{#foreach $T.data as info}
								<div class="result user_fines" rel="{$T.info.id}">
									<div class="record">
										{#if $T.info.title}<label><i18n:text key="search.bibliographic.title" /></label>: <strong>{$T.info.title}</strong><br/>{#/if}
										<label><i18n:text key="circulation.lending.fine_value" /></label>: <%= Configurations.getString((String) request.getAttribute("schema"), Constants.CONFIG_CURRENCY) %> {_f($T.info.value || 0, 'n2')}<br/>
										
										{#if $T.info.payment}<label><i18n:text key="circulation.lending.payment_date" /></label>: {_d($T.info.payment, 'D')}<br/>
										{#else}
											<div class="description" style="color:#dc2626; font-weight:700;">
												<p><i18n:text key="circulation.user.fine.pending" /></p>
											</div>
										{#/if}
									</div>
									{#if !$T.info.payment}
										<div class="fines_buttons">
											<a class="button center" onclick="CirculationSearch.payFine('{$T.info.id}', false);"><i18n:text key="circulation.lending.buttons.pay_fine" /></a>
											<a class="button center" onclick="CirculationSearch.payFine('{$T.info.id}', true);"><i18n:text key="circulation.lending.buttons.dismiss_fine" /></a>
										</div>
									{#/if}
									<div class="clear"></div>
								</div>
							{#/for}
						{#else}
							<p style="padding: 10px; color: #64748b; font-size: 11px;"><i18n:text key="circulation.user.no_fines" /></p>
						{#/if}
					--></textarea>
				</div>
				<div class="clear"></div>
			</div>
			
			<div class="tabs_extra_content">
				<div class="tab_extra_content biblivre_form" data-tab="form">
					<div id="biblivre_circulation_form"></div>
					<textarea id="biblivre_circulation_form_template" class="template"><!-- 
						<fieldset style="border:none; padding:0; margin:0;">
							<div class="fields">
								{#foreach CirculationInput.userFields as userfield}
									<div class="field">
										<div class="label">{_('circulation.custom.user_field.' + $T.userfield.key)}</div>
										<div class="value">
											{#if $T.userfield.type == 'string'}
												<input type="text" name="{$T.userfield.key}" maxlength="{$T.userfield.maxLength || ''}" value="{($T.fields || {})[$T.userfield.key]}">
											{#/if}
											{#if $T.userfield.type == 'text'}
												{$('<textarea/>').attr('name', $T.userfield.key).text(($T.fields || {})[$T.userfield.key] || '')[0].outerHTML}
											{#/if}
											{#if $T.userfield.type == 'list' && $T.userfield.maxLength > 0}
												<select name="{$T.userfield.key}">
													{#if !$T.userfield.required}<option value="">{_('circulation.custom.user_field.select.default')}</option>{#/if}
													{#for index = 1 to $T.userfield.maxLength}
														<option value="{$T.index}" {#if ($T.fields && $T.fields[$T.userfield.key] && $T.fields[$T.userfield.key] == $T.index)}selected="selected"{#/if}>{_('circulation.custom.user_field.' + $T.userfield.key + '.' + $T.index)}</option> 
													{#/for}
												</select>
											{#/if}
											{#if $T.userfield.type == 'date' || $T.userfield.type == 'datetime'}
												<input type="text" class="datepicker" name="{$T.userfield.key}" maxlength="{$T.userfield.maxLength || ''}" value="{($T.fields || {})[$T.userfield.key]}">
											{#/if}
											{#if $T.userfield.type == 'boolean'}
												<input type="checkbox" name="{$T.userfield.key}" value="true" {#if ($T.fields && $T.fields[$T.userfield.key] && $T.fields[$T.userfield.key] == 'true')}checked="checked"{#/if} style="width: auto;">
											{#/if}
										</div>
										<div class="clear"></div>
									</div>
								{#/for}							
							</div>
						</fieldset>
					--></textarea>
				</div>		
			</div>		
			
			<div class="footer_buttons">
				<div class="edit">
					<a class="main_button center" onclick="CirculationInput.saveRecord();">💾 <i18n:text key="common.save" /></a>
					<a class="button center" onclick="CirculationInput.saveRecord(true);"><i18n:text key="common.save_as_new" /></a>
					<a class="button center" onclick="CirculationInput.cancelEdit();"><i18n:text key="common.cancel" /></a>
				</div>
				
				<div class="new">
					<a class="main_button center" onclick="CirculationInput.saveRecord();">💾 <i18n:text key="common.save" /></a>
					<a class="button center" onclick="CirculationInput.cancelEdit();"><i18n:text key="common.cancel" /></a>
				</div>
			</div>	
		</div>
	
		<!-- CAIXA DE PESQUISA -->
		<div class="search_box">
			<div class="simple_search submit_on_enter">
				<div class="query">
					<input type="text" name="query" class="big_input auto_focus" placeholder="<i18n:text key="search.user.simple_term_title" />"/>
				</div>
				<div class="buttons">
					<label class="search_label"><i18n:text key="search.user.field" />:</label>
					<select name="field" class="combo">
						<option value=""><i18n:text key="search.user.name_or_id" /></option>
						<c:forEach var="field" items="<%= UserFields.getSearchableFields((String) request.getAttribute(\"schema\")) %>" >
							<option value="${field.key}"><i18n:text key="${user_field_prefix}${field.key}" /></option>
						</c:forEach>
					</select>
					<a class="main_button arrow_right" onclick="CirculationSearch.search('simple');"><i18n:text key="search.common.button.list_all" /></a>
				</div>
			</div>
			
			<div class="advanced_search submit_on_enter" style="display:none;">
				<div class="query">
					<input type="text" name="query" class="big_input auto_focus" placeholder="<i18n:text key="search.user.simple_term_title" />"/>
				</div>
				<div class="filter_search" style="margin-top: 6px;">
					<div class="fleft filter_field" style="margin-right: 8px;">
						<label class="search_label"><i18n:text key="search.user.field" /></label>
						<select name="field" class="combo combo_expand">
							<option value=""><i18n:text key="search.user.name_or_id" /></option>
							<c:forEach var="field" items="<%= UserFields.getSearchableFields((String) request.getAttribute(\"schema\")) %>" >
								<option value="${field.key}"><i18n:text key="${user_field_prefix}${field.key}" /></option>
							</c:forEach>
						</select>
					</div>
					<div class="fleft filter_date" style="margin-right: 8px;">
						<label class="search_label"><i18n:text key="search.common.registered_between" /></label>
						<input type="text" name="created_start" class="small_input datepicker" style="width:75px;" /> - <input type="text" name="created_end" class="small_input datepicker" style="width:75px;" />
					</div>
					<div class="clear"></div>
					<div class="filter_checkbox" style="margin-top: 4px;">
						<input type="checkbox" name="users_with_pending_fines" id="users_with_pending_fines" value="true">
						<label class="search_label" for="users_with_pending_fines"><i18n:text key="circulation.user.users_with_pending_fines" /></label>
					</div>
				</div>

				<div class="clear_search ico_clear" style="margin-top: 4px;">
					<a href="javascript:void(0);" onclick="CirculationSearch.clearAdvancedSearch();">✕ <i18n:text key="search.common.clear_search" /></a>
				</div>

				<div class="buttons" style="margin-top: 6px;">
					<a class="main_button arrow_right" onclick="CirculationSearch.search('advanced');"><i18n:text key="search.common.button.list_all" /></a>
					<div class="clear"></div>
				</div>
			</div>
		</div>
		
		<div class="search_results_area">
			<div class="search_loading_indicator loading_indicator"></div>
			<div class="paging_bar"></div>
		
			<div class="search_results_box">
				<div class="search_results"></div>
				<textarea class="search_results_template template"><!-- 
					{#foreach $T.data as record}
						<div class="result {#cycle values=['odd', 'even']}" rel="{$T.record.id}">
							<div class="record">
								{#if $T.record.name}<label><i18n:text key="circulation.user_field.name" /></label>: <strong>{$T.record.name}</strong><br/>{#/if}
								<label><i18n:text key="circulation.user_field.id" /></label>: {$T.record.enrollment}<br/>
								<label><i18n:text key="circulation.user_field.type" /></label>: {$T.record.type_name}<br/>
								<div class="user_status_{$T.record.status}"><label><i18n:text key="circulation.user_field.status" /></label>: {_('circulation.user_status.' + $T.record.status)}</div>
							</div>
							<div class="buttons">
								<a class="button center" rel="open_item" onclick="CirculationSearch.openResult('{$T.record.id}');">👉 <i18n:text key="search.user.open_item_button" /></a>
								{#if $T.record.status != 'blocked'}
									<a class="button center" rel="block_user" onclick="CirculationSearch.blockUser('{$T.record.id}');">🔒 <i18n:text key="circulation.user.button.block" /></a>
								{#else}
									<a class="button center" rel="unblock_user" onclick="CirculationSearch.unblockUser('{$T.record.id}');">🔓 <i18n:text key="circulation.user.button.unblock" /></a>
								{#/if}
							</div>
							<div class="clear"></div>
						</div>
					{#/for}
				--></textarea>
			</div>
			<div class="paging_bar"></div>		
		</div>
	</div>	

	<!-- POPUP DE FOTO -->
	<div id="photo_upload_popup" class="popup">
		<div class="close" onclick="CirculationInput.closePhotoUploadPopup();">✕ <i18n:text key="common.close" /></div>

		<fieldset style="border:none; padding:0; margin:0;">
			<legend style="font-size:13px; font-weight:800; color:#0f172a; margin-bottom:8px;"><i18n:text key="circulation.user_field.photo" /></legend>
			<div id="photo_area"></div>
			<div class="progress" style="margin: 8px 0;">
				<div class="progress_bar">
					<div class="progress_bar_outer"><div class="progress_bar_inner"></div></div>
				</div>
			</div>
			<div class="buttons" style="display:flex; gap:6px; margin-top:8px;">
				<a class="button" onclick="CirculationInput.closePhotoUploadPopup();"><i18n:text key="common.cancel" /></a>
				<a class="button main_button" onclick="CirculationInput.applyPhotoSelection();"><i18n:text key="common.ok" /></a>
			</div>			
		</fieldset>
	</div>
</layout:body>
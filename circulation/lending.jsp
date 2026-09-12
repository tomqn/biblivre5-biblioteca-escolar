<%@page import="biblivre.core.configurations.Configurations"%>
<%@page import="biblivre.marc.MaterialType"%>
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
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.cataloging.css" />
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

	<style type="text/css">
		/* =================================================================
		   ESTILIZAÇÃO ULTRA-COMPACTA DARK (SEM ESPAÇOS SOBRANDO)
		   ================================================================= */
		body, #circulation_search, #holding_search {
			font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif !important;
			color: #0f172a;
		}

		/* LARGURA CONTROLADA E COMPACTA */
		#circulation_search, #holding_search {
			max-width: 960px !important;
			margin: 0 auto !important;
			padding: 0 8px !important;
			box-sizing: border-box !important;
		}
		#circulation_search {
			margin-bottom: 12px !important;
		}

		/* ZERA ESPAÇADORES DO SISTEMA */
		.ncspacer {
			display: none !important;
			height: 0 !important;
			margin: 0 !important;
		}

		/* Ajuda mínima do topo */
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

		/* CABEÇALHO ESCURO JUSTO */
		.page_title {
			background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%) !important;
			border-radius: 8px !important;
			padding: 8px 14px !important;
			margin-bottom: 4px !important; /* Colado na busca */
			display: flex !important;
			align-items: center !important;
			gap: 8px !important;
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
		}

		/* BARRA DE NAVEGAÇÃO: FICA OCULTA ATÉ SER NECESSÁRIA */
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

		/* CAIXA DE PESQUISA GRUDADA NO CABEÇALHO */
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
		.simple_search .query, .simple_search .wide_query {
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

		/* INPUTS E COMBO COMPACTOS */
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

		/* BOTÃO LISTAR TODOS / PESQUISAR ESCURO COMPACTO */
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

		.clear_simple_search {
			margin-top: 4px !important;
			font-size: 10px !important;
		}
		.clear_simple_search a {
			color: #64748b !important;
			text-decoration: none !important;
			font-weight: 600 !important;
		}
		.clear_simple_search a:hover {
			color: #dc2626 !important;
		}

		/* CARDS DE RESULTADO DA BUSCA */
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

		/* ZERA ÁREA DO BOTÃO (SEM FUNDO/BORDA CIRCULAR) */
		.search_results .result .buttons {
			background: transparent !important;
			border: none !important;
			padding: 0 !important;
			margin: 0 !important;
			box-shadow: none !important;
			display: flex !important;
			align-items: center !important;
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
		.record .user_status_0, .record .user_status_active {
			background: #ecfdf5 !important;
			color: #059669 !important;
			border: 1px solid #a7f3d0 !important;
		}
		.record .user_status_1, .record .user_status_blocked {
			background: #fef2f2 !important;
			color: #dc2626 !important;
			border: 1px solid #fecaca !important;
		}

		/* BOTÃO SELECIONAR LEITOR */
		a[rel="open_item"] {
			background: #0f172a !important;
			color: #ffffff !important;
			border: none !important;
			border-radius: 5px !important;
			height: 26px !important;
			padding: 0 10px !important;
			font-size: 11px !important;
			font-weight: 700 !important;
			cursor: pointer !important;
			text-decoration: none !important;
			display: inline-flex !important;
			align-items: center !important;
			gap: 3px !important;
			white-space: nowrap !important;
		}
		a[rel="open_item"]:hover {
			background: #1e293b !important;
			color: #ffffff !important;
		}

		/* CARTÃO LEITOR SELECIONADO COMPACTO */
		.selected_highlight {
			background: #ffffff !important;
			border: 1px solid #cbd5e1 !important;
			border-radius: 8px !important;
			padding: 10px 14px !important;
			margin-bottom: 8px !important;
		}
		.selected_highlight .record {
			font-size: 11px !important;
			line-height: 1.35 !important;
		}
		.selected_highlight .record label {
			font-weight: 700 !important;
			color: #0f172a !important;
			display: inline-block !important;
			min-width: 75px !important;
		}
		.selected_highlight .user_photo {
			width: 60px !important;
			height: 60px !important;
			border-radius: 6px !important;
			border: 1px solid #e2e8f0 !important;
			object-fit: cover !important;
			margin-bottom: 4px !important;
		}

		/* Livros emprestados ao leitor */
		.selected_highlight .user_lending {
			background: #f8fafc !important;
			border: 1px solid #e2e8f0 !important;
			border-left: 3px solid #0f172a !important;
			border-radius: 5px !important;
			padding: 6px 10px !important;
			margin-top: 6px !important;
			display: flex !important;
			justify-content: space-between !important;
			align-items: center !important;
			gap: 6px !important;
		}

		/* Botões de Ação de Livros */
		.lending_buttons a.button, .search_results .result .buttons a.button {
			border-radius: 5px !important;
			height: 26px !important;
			padding: 0 8px !important;
			font-size: 10px !important;
			font-weight: 700 !important;
			text-decoration: none !important;
			display: inline-flex !important;
			align-items: center !important;
			border: none !important;
		}
		a[onclick*="lend("] {
			background: #059669 !important;
			color: #ffffff !important;
		}
		a[onclick*="returnLending"] {
			background: #0f172a !important;
			color: #ffffff !important;
		}
		a[onclick*="renewLending"] {
			background: #d97706 !important;
			color: #ffffff !important;
		}
		.button.disabled {
			background: #f1f5f9 !important;
			color: #94a3b8 !important;
			cursor: not-allowed !important;
		}

		.value_error {
			background: #fef2f2 !important;
			color: #dc2626 !important;
			border: 1px solid #fecaca !important;
			padding: 1px 4px !important;
			border-radius: 3px !important;
			font-weight: 800 !important;
			font-size: 10px !important;
		}

		/* POPUP */
		.popup {
			background: #ffffff !important;
			border: 1px solid #cbd5e1 !important;
			border-radius: 8px !important;
			box-shadow: 0 10px 24px rgba(15, 23, 42, 0.2) !important;
			padding: 14px !important;
		}
		.popup fieldset.fine {
			border: none !important;
			padding: 0 !important;
			margin: 0 !important;
		}
		.popup fieldset.fine legend {
			font-size: 13px !important;
			font-weight: 800 !important;
			color: #0f172a !important;
			margin-bottom: 6px !important;
		}
		.popup .close {
			color: #64748b !important;
			font-size: 11px !important;
			font-weight: 700 !important;
		}
	</style>

	<script type="text/javascript" src="static/scripts/biblivre.search.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.circulation.search.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.holding.search.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.circulation.lending.js"></script>
	<script type="text/javascript">
		var CirculationSearch = CreateSearch(CirculationSearchClass, {
			type: 'circulation.lending',
			prefix: 'lending.user',
			root: '#circulation_search',
			searchAction: 'user_search',
			paginateAction: 'user_search',
			openAction: 'list',
			autoSelect: true,
			enableTabs: false,
			enableHistory: false
		});

		var HoldingSearch = CreateSearch(HoldingSearchClass, {
			type: 'circulation.lending',
			prefix: 'lending.holding',
			root: '#holding_search',
			paginateAction: 'search',
			autoSelect: false,
			enableTabs: false,
			enableHistory: false
		});
	</script>
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.modern.css" />
</layout:head>

<%
	List<UserTypeDTO> userTypes = UserTypeBO.getInstance((String) request.getAttribute("schema")).list();
%>

<layout:body>
	<c:set var="user_field_prefix" value="<%= Constants.TRANSLATION_USER_FIELD %>" scope="page" />
	<div class="page_help"><i18n:text key="circulation.lending.page_help" /></div>

	<!-- PAINEL 1: PESQUISAR LEITOR -->
	<div id="circulation_search">
		<div class="page_title">
			<div class="image"><img src="static/images/titles/search.png" /></div>
			<div class="text"><i18n:text key="circulation.lending.users.title" /></div>
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
			<div class="record">
				<div class="fright" style="text-align: center">
					{#if $T.user.photo_id}
						<img class="user_photo" src="DigitalMediaController/?id={$T.user.photo_id}"/>
					{#else}
						<img class="user_photo" src="static/images/photo.png"/>
					{#/if}
					<div class="ncspacer"></div>
					<a class="button center disabled" onclick="CirculationSearch.printReceipt();" id="lending_receipt_button"><i18n:text key="circulation.lending.button.print_receipt" /></a>
				</div>

				{#if $T.user.name}<label><i18n:text key="circulation.user_field.name" /></label>: <strong>{$T.user.name}</strong><br/>{#/if}
				<label><i18n:text key="circulation.user_field.id" /></label>: {$T.user.enrollment}<br/>
				<label><i18n:text key="circulation.user_field.type" /></label>: {$T.user.type_name}<br/>
				<div class="user_status_{$T.user.status}"><label><i18n:text key="circulation.user_field.status" /></label>: {_('circulation.user_status.' + $T.user.status)}</div>
				{#if $T.user.fines}<br/><label><i18n:text key="circulation.user_field.fines" /></label>: <span class="value_error">{$T.user.fines}</span><br/>{#/if}

				<div class="ncspacer"></div>
				<div style="margin-top: 4px; font-weight: 700; color: #0f172a; font-size: 11px;">
					📚 <i18n:text key="circulation.lending.lending_count" />: {($T.lendingInfo || {}).length || 0}
				</div>

				<div class="clear"></div>
				
				{#if $T.lendingInfo && $T.lendingInfo.length > 0}
					{#foreach $T.lendingInfo as info}
						<div class="result user_lending" rel="{$T.info.lending.id}">
							<div class="record">
								{#if $T.info.biblio.title}<label><i18n:text key="search.bibliographic.title" /></label>: <strong>{$T.info.biblio.title}</strong><br/>{#/if}
								{#if $T.info.biblio.author}<label><i18n:text key="search.bibliographic.author" /></label>: {$T.info.biblio.author}<br/>{#/if}
								{#if $T.info.biblio.publication_year}<label><i18n:text key="search.bibliographic.publication_year" /></label>: {$T.info.biblio.publication_year}<br/>{#/if}
								{#if $T.info.biblio.shelf_location || $T.info.holding.shelf_location || $T.info.holding.location_d}
									<label><i18n:text key="search.bibliographic.shelf_location" /></label>: {$T.info.holding.shelf_location || $T.info.biblio.shelf_location || ''} {$T.info.holding.location_d || ''}<br/>
								{#/if}
								{#if $T.info.biblio.isbn}<label><i18n:text key="search.bibliographic.isbn" /></label>: {$T.info.biblio.isbn}<br/>{#/if}

								<div class="ncspacer"></div>					

								<label><i18n:text key="search.holding.accession_number" /></label>: {$T.info.holding.accession_number}<br/>
								<label><i18n:text key="circulation.lending.lending_date" /></label>: {_d($T.info.lending.created,'f')}<br/>
								{#if $T.info.lending.expectedReturnDate}<label><i18n:text key="circulation.lending.expected_return_date" /></label>: <strong>{_d($T.info.lending.expectedReturnDate, 'D')}</strong><br/>{#/if}

								{#if $T.info.lending.daysLate > 0}
									<div class="ncspacer"></div>
									<label><i18n:text key="circulation.lending.days_late" /></label>: <span class="value_error">{ _f($T.info.lending.daysLate || 0) } dias</span><br/>
									<label><i18n:text key="circulation.lending.estimated_fine" /></label>: <span class="value_error"><%= Configurations.getString((String) request.getAttribute("schema"), Constants.CONFIG_CURRENCY) %> {_f($T.info.lending.estimatedFine || 0, 'n2') }</span><br/>
								{#/if}
							</div>
							<div class="lending_buttons">
								{#if $T.info.lending}
									{#if $T.info.lending.daysLate > 0}
										<a class="button center disabled"><i18n:text key="circulation.lending.button.renew" /></a>
									{#else}
										<a class="button center" onclick="HoldingSearch.renewLending({#var $T.info});">🔄 <i18n:text key="circulation.lending.button.renew" /></a>
									{#/if}

									<a class="button center" onclick="HoldingSearch.returnLending({#var $T.info});">📥 <i18n:text key="circulation.lending.button.return" /></a>
								{#/if}
							</div>
							<div class="clear"></div>
						</div>
					{#/for}
				{#/if}
			</div>
		--></textarea>
	
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
			<div class="clear_simple_search">
				<a href="javascript:void(0);" onclick="CirculationSearch.clearSimpleSearch();">✕ <i18n:text key="search.common.clear_simple_search" /></a>
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
								{#if $T.record.user.name}<label><i18n:text key="circulation.user_field.name" /></label>: <strong>{$T.record.user.name}</strong><br/>{#/if}
								<label><i18n:text key="circulation.user_field.id" /></label>: {$T.record.user.enrollment}<br/>
								<label><i18n:text key="circulation.user_field.type" /></label>: {$T.record.user.type_name}<br/>
								<div class="user_status_{$T.record.user.status}"><label><i18n:text key="circulation.user_field.status" /></label>: {_('circulation.user_status.' + $T.record.user.status)}</div>
								<br/>
								<label><i18n:text key="circulation.lending.lending_count" /></label>: <strong>{($T.record.lendingInfo || {}).length || 0}</strong>
							</div>
							<div class="buttons">
								<a class="button center" rel="open_item" onclick="CirculationSearch.openResult('{$T.record.id}');">👉 <i18n:text key="circulation.lending.button.select_reader" /></a>
							</div>
							<div class="clear"></div>
						</div>
					{#/for}
				--></textarea>
			</div>
			<div class="paging_bar"></div>		
		</div>
	</div>

	<!-- PAINEL 2: PESQUISAR EXEMPLAR -->
	<div id="holding_search">
		<div class="page_title">
			<div class="image"><img src="static/images/titles/search.png" /></div>
			<div class="text"><i18n:text key="circulation.lending.holdings.title" /></div>
			<div class="clear"></div>
		</div>
				
		<div class="page_navigation">
			<a href="javascript:void(0);" class="button paging_button back_to_search" onclick="HoldingSearch.closeResult();"><i18n:text key="search.common.back_to_search" /></a>

			<div class="fright">
				<a href="javascript:void(0);" class="button paging_button paging_button_prev" onclick="HoldingSearch.previousResult();">‹ <i18n:text key="search.common.previous" /></a>
				<span class="search_count"></span>
				<a href="javascript:void(0);" class="button paging_button paging_button_next" onclick="HoldingSearch.nextResult();"><i18n:text key="search.common.next" /> ›</a>
			</div>
			<div class="clear"></div>
		</div>
	
		<div class="clear"></div>
	
		<div class="selected_highlight"></div>
		<textarea class="selected_highlight_template template"><!-- 
			<div class="record">
				{#if $T.title}<label><i18n:text key="search.bibliographic.title" /></label>: <strong>{$T.title}</strong><br/>{#/if}
				{#if $T.author}<label><i18n:text key="search.bibliographic.author" /></label>: {$T.author}<br/>{#/if}
				{#if $T.publication_year}<label><i18n:text key="search.bibliographic.publication_year" /></label>: {$T.publication_year}<br/>{#/if}
				{#if $T.shelf_location}<label><i18n:text key="search.bibliographic.shelf_location" /></label>: {$T.shelf_location}<br/>{#/if}
				{#if $T.isbn}<label><i18n:text key="search.bibliographic.isbn" /></label>: {$T.isbn}<br/>{#/if}
				<label><i18n:text key="search.bibliographic.id" /></label>: {$T.id}<br/>
			</div>
		--></textarea>
		
		<div class="search_box">
			<div class="simple_search submit_on_enter">
				<div class="wide_query">
					<input type="text" name="query" class="big_input" placeholder="<i18n:text key="search.holding.accession_number" />"/>
				</div>
				<div class="buttons">
					<a class="main_button arrow_right" onclick="HoldingSearch.search('simple');"><i18n:text key="search.common.button.list_all" /></a>
				</div>
			</div>
			<div class="filter_search" style="margin-top: 4px;">
				<div class="filter_checkbox">
					<input type="checkbox" name="holding_list_lendings" id="holding_list_lendings" value="true">
					<label class="search_label" for="holding_list_lendings" style="cursor: pointer;"><i18n:text key="circulation.lendings.holding_list_lendings" /></label>
				</div>
			</div>
			<div class="clear_simple_search">
				<a href="javascript:void(0);" onclick="HoldingSearch.clearSimpleSearch();">✕ <i18n:text key="search.common.clear_simple_search" /></a>
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
								{#if $T.record.biblio.title}<label><i18n:text key="search.bibliographic.title" /></label>: <strong>{$T.record.biblio.title}</strong><br/>{#/if}
								{#if $T.record.biblio.author}<label><i18n:text key="search.bibliographic.author" /></label>: {$T.record.biblio.author}<br/>{#/if}
								{#if $T.record.holding.accession_number}<label><i18n:text key="search.holding.accession_number" /></label>: <strong>{$T.record.holding.accession_number}</strong><br/>{#/if}
								{#if $T.record.holding.availability}<label><i18n:text key="search.holding.availability" /></label>: {_('cataloging.holding.availability.' + $T.record.holding.availability)}<br/>{#/if}

								{#if ($T.record.lending == undefined) && ($T.record.biblio.holdings_reserved > 0) && ($T.record.biblio.holdings_reserved >= $T.record.biblio.holdings_available) && CirculationSearch.selectedRecord && ($.inArray($T.record.biblio.id, CirculationSearch.selectedRecord.reservedRecords) == -1)}
									<div class="ncspacer"></div>
									<div class="warn"><strong><i18n:text key="circulation.lending.reserved.warning" /></strong></div>
								{#/if}
								
								{#if $T.record.lending !== undefined}
									<div class="user_lending" style="margin-top: 4px; background:#f8fafc; border-left:3px solid #0f172a; border-radius:4px; padding:4px 8px;">				
										<label><i18n:text key="circulation.lending.holding_lent_to_the_following_reader" />:</label><br/>
										{#if $T.record.user.name}<label><i18n:text key="circulation.user_field.name" /></label>: <strong>{$T.record.user.name}</strong> ({$T.record.user.enrollment})<br/>{#/if}
										<label><i18n:text key="circulation.lending.lending_date" /></label>: {_d($T.record.lending.created,'f')}<br/>
										{#if $T.record.lending.expectedReturnDate}<label><i18n:text key="circulation.lending.expected_return_date" /></label>: <strong>{_d($T.record.lending.expectedReturnDate, 'D')}</strong><br/>{#/if}
	
										{#if $T.record.lending.daysLate > 0}
											<div class="ncspacer"></div>
											<label><i18n:text key="circulation.lending.days_late" /></label>: <span class="value_error">{ _f($T.record.lending.daysLate || 0) } dias</span><br/>
											<label><i18n:text key="circulation.lending.estimated_fine" /></label>: <span class="value_error"><%= Configurations.getString((String) request.getAttribute("schema"), Constants.CONFIG_CURRENCY) %> {_f($T.record.lending.estimatedFine || 0, 'n2') }</span><br/>
										{#/if}
									</div>
								{#/if}
							</div>
							<div class="buttons">
								{#if $T.record.lending}
									{#if $T.record.lending.daysLate > 0}										
										<a class="button center disabled"><i18n:text key="circulation.lending.button.renew" /></a>
									{#else}
										<a class="button center" onclick="HoldingSearch.renewLending({#var $T.record});">🔄 <i18n:text key="circulation.lending.button.renew" /></a>
									{#/if}
									<a class="button center" onclick="HoldingSearch.returnLending({#var $T.record});">📥 <i18n:text key="circulation.lending.button.return" /></a>
								{#elseif $T.record.holding.availability == 'available'}
									<a class="button center" onclick="HoldingSearch.lend('{$T.record.holding.id}');">📗 <i18n:text key="circulation.lending.button.lend" /></a>
								{#else}
									<a class="button disabled center"><i18n:text key="circulation.lending.button.unavailable" /></a>
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
		
	<!-- POPUP DE MULTA -->
	<div id="fine_popup" class="popup">
		<div class="close" onclick="HoldingSearch.closeFinePopup();">✕ <i18n:text key="common.close" /></div>

		<fieldset class="fine">
			<legend><i18n:text key="circulation.lending.fine_popup.title" /></legend>

			<div class="description" style="font-size:11px; line-height:1.3; margin-bottom:8px;">
				<p style="color:#64748b; margin-bottom:6px;"><i18n:text key="circulation.lending.fine_popup.description" /></p>
				<label><i18n:text key="circulation.lending.days_late" /></label>: <span class="days_late value_error"></span><br/>
				<label><i18n:text key="circulation.lending.daily_fine" /></label>: <%= Configurations.getString((String) request.getAttribute("schema"), Constants.CONFIG_CURRENCY) %> <span class="daily_fine"></span><br/>
				<div style="margin-top:4px;">
					<label><i18n:text key="circulation.lending.fine_value" /></label>: <%= Configurations.getString((String) request.getAttribute("schema"), Constants.CONFIG_CURRENCY) %> 
					<input type="text" name="fine_value" class="big_input" style="width:90px !important; display:inline-block !important; height:26px !important;" /><br/>
				</div>
			</div>

			<div class="buttons" style="display:flex; gap:5px;">
				<a class="button" onclick="HoldingSearch.applyFine();"><i18n:text key="circulation.lending.buttons.apply_fine" /></a>
				<a class="button" style="background:#059669 !important; color:#fff !important;" onclick="HoldingSearch.payFine();"><i18n:text key="circulation.lending.buttons.pay_fine" /></a>
				<a class="button" onclick="HoldingSearch.dismissFine();"><i18n:text key="circulation.lending.buttons.dismiss_fine" /></a>
			</div>
		</fieldset>
	</div>
</layout:body>
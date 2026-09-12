<%@page import="biblivre.administration.accesscards.AccessCardStatus"%>
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
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

	<script type="text/javascript" src="static/scripts/biblivre.search.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.circulation.search.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.administration.accesscards.search.js"></script>
	<script type="text/javascript" src="static/scripts/biblivre.circulation.access_control.js"></script>	
	
	<script type="text/javascript">
		var CirculationSearch = CreateSearch(CirculationSearchClass, {
			type: 'circulation.accesscontrol',
			prefix: 'accesscontrol.user',
			root: '#circulation_search',
			searchAction: 'user_search',
			paginateAction: 'user_search',
			autoSelect: true,
			enableTabs: false,
			enableHistory: false
		});

		var AccessCardsSearch = CreateSearch(AccessCardsSearchClass, {
			type: 'circulation.accesscontrol',
			prefix: 'accesscontrol.card',
			root: '#access_cards',
			searchAction: 'card_search',
			paginateAction: 'card_search',
			enableTabs: false,
			enableHistory: false
		});

		Core.subscribe(CirculationSearch.prefix + 'record-selected', function(e) {
			AccessCardsSearch.root.find('input[name=query]').focus();
		});
	</script>

	<style type="text/css">
		body, #circulation_search, #access_cards { font-family: 'Plus Jakarta Sans', system-ui, sans-serif !important; color: #0f172a; }
		#circulation_search, #access_cards { max-width: 960px !important; margin: 0 auto !important; padding: 0 8px !important; }
		#circulation_search { margin-bottom: 10px !important; }
		.ncspacer { display: none !important; height: 0 !important; margin: 0 !important; }
		.page_help { background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 6px !important; color: #64748b !important; font-size: 11px !important; padding: 5px 10px !important; margin-bottom: 8px !important; }
		.page_title { background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%) !important; border-radius: 8px !important; padding: 8px 14px !important; margin-bottom: 4px !important; display: flex !important; align-items: center !important; gap: 8px !important; }
		.page_title .image { width: 24px !important; height: 24px !important; background: rgba(255, 255, 255, 0.12) !important; border-radius: 5px !important; display: flex !important; align-items: center !important; justify-content: center !important; float: none !important; }
		.page_title .image img { width: 13px !important; height: 13px !important; filter: brightness(0) invert(1) !important; }
		.page_title .text { font-size: 13px !important; font-weight: 800 !important; color: #ffffff !important; float: none !important; margin: 0 !important; }
		.search_box { background: #ffffff !important; border: 1px solid #e2e8f0 !important; border-radius: 8px !important; padding: 8px 12px !important; margin-top: 4px !important; margin-bottom: 6px !important; }
		.simple_search { display: flex !important; align-items: center !important; flex-wrap: wrap !important; gap: 8px !important; }
		.simple_search .query, .simple_search .wide_query { flex: 1 !important; min-width: 180px !important; float: none !important; }
		.simple_search .buttons { display: flex !important; align-items: center !important; gap: 6px !important; margin: 0 !important; padding: 0 !important; border: none !important; background: transparent !important; box-shadow: none !important; }
		input[type="text"].big_input { height: 30px !important; border-radius: 5px !important; border: 1px solid #cbd5e1 !important; padding: 0 10px !important; font-size: 12px !important; color: #0f172a !important; outline: none !important; width: 100% !important; }
		select.combo { height: 30px !important; border-radius: 5px !important; border: 1px solid #cbd5e1 !important; padding: 0 6px !important; font-size: 11px !important; background: #ffffff !important; outline: none !important; }
		.main_button { background: #0f172a !important; color: #ffffff !important; border: none !important; border-radius: 5px !important; height: 30px !important; padding: 0 12px !important; font-size: 11px !important; font-weight: 700 !important; display: inline-flex !important; align-items: center !important; cursor: pointer !important; }
		.main_button:hover { background: #1e293b !important; }
		.search_results .result { background: #ffffff !important; border: 1px solid #e2e8f0 !important; border-radius: 6px !important; padding: 6px 12px !important; margin-bottom: 5px !important; display: flex !important; align-items: center !important; justify-content: space-between !important; gap: 10px !important; }
		.search_results .result .record { flex: 1 !important; font-size: 11px !important; line-height: 1.3 !important; }
		.search_results .result .record label { font-weight: 700 !important; color: #0f172a !important; display: inline-block !important; min-width: 85px !important; }
		.search_results .result .buttons { background: transparent !important; border: none !important; padding: 0 !important; margin: 0 !important; box-shadow: none !important; display: flex !important; align-items: center !important; }
		a[rel="open_item"] { background: #0f172a !important; color: #ffffff !important; border-radius: 5px !important; height: 26px !important; padding: 0 10px !important; font-size: 11px !important; font-weight: 700 !important; border: none !important; display: inline-flex !important; align-items: center !important; }
		a[onclick*="bindCard"] { background: #059669 !important; color: #ffffff !important; border-radius: 5px !important; height: 26px !important; padding: 0 10px !important; font-size: 11px !important; font-weight: 700 !important; border: none !important; }
		a[onclick*="unbindCard"] { background: #dc2626 !important; color: #ffffff !important; border-radius: 5px !important; height: 26px !important; padding: 0 10px !important; font-size: 11px !important; font-weight: 700 !important; border: none !important; }
		.selected_highlight { background: #ffffff !important; border: 1px solid #cbd5e1 !important; border-radius: 8px !important; padding: 10px 14px !important; margin-bottom: 8px !important; }
	</style>
</layout:head>

<%
	List<UserTypeDTO> userTypes = UserTypeBO.getInstance((String) request.getAttribute("schema")).list();
%>

<layout:body>
	<div class="page_help"><i18n:text key="circulation.access_control.page_help" /></div>

	<c:set var="user_field_prefix" value="<%= Constants.TRANSLATION_USER_FIELD %>" scope="page" />

	<div id="circulation_search">
		<div class="page_title">
			<div class="image"><img src="static/images/titles/search.png" /></div>
			<div class="text"><i18n:text key="circulation.access.user.search" /></div>
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
				{#if $T.user.name}<label><i18n:text key="circulation.user_field.name" /></label>: <strong>{$T.user.name}</strong><br/>{#/if}
				<label><i18n:text key="circulation.user_field.id" /></label>: {$T.user.enrollment}<br/>
				<label><i18n:text key="circulation.user_field.type" /></label>: {$T.user.type_name}<br/>
				<div class="user_status_{$T.user.status}"><label><i18n:text key="circulation.user_field.status" /></label>: {_('circulation.user_status.' + $T.user.status)}</div>
				{#if $T.accessCard}<br/><label><i18n:text key="administration.accesscards.field.code" /></label>: <strong>{$T.accessCard.code}</strong><br/>{#/if}
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
					<a class="main_button arrow_right" onclick="CirculationSearch.search('simple');"><i18n:text key="search.common.button.search" /></a>
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
						<div class="result {#cycle values=['odd', 'even']}" rel="{$T.record.user.id}">
							<div class="record">
								{#if $T.record.user.name}<label><i18n:text key="circulation.user_field.name" /></label>: <strong>{$T.record.user.name}</strong><br/>{#/if}
								<label><i18n:text key="circulation.user_field.id" /></label>: {$T.record.user.enrollment}<br/>
								<div class="user_status_{$T.record.user.status}"><label><i18n:text key="circulation.user_field.status" /></label>: {_('circulation.user_status.' + $T.record.user.status)}</div>
								{#if $T.record.accessCard}<br/><label><i18n:text key="administration.accesscards.field.code" /></label>: <strong>{$T.record.accessCard.code}</strong><br/>{#/if}				
							</div>
							<div class="buttons">
								<a class="button center" rel="open_item" onclick="CirculationSearch.openResult('{$T.record.user.id}');">👉 <i18n:text key="search.user.select_item_button" /></a>
							</div>
							<div class="clear"></div>
						</div>
					{#/for}
				--></textarea>
			</div>
			<div class="paging_bar"></div>		
		</div>
	</div>
	
	<div id="access_cards">
		<div class="page_title">
			<div class="image"><img src="static/images/titles/search.png" /></div>
			<div class="simple_search text"><i18n:text key="menu.administration_access_cards" /></div>
			<div class="clear"></div>
		</div>

		<div class="page_navigation">
			<a href="javascript:void(0);" class="button paging_button back_to_search" onclick="AccessCardsSearch.closeResult();"><i18n:text key="search.common.back_to_search" /></a>
			<div class="fright">
				<a href="javascript:void(0);" class="button paging_button paging_button_prev" onclick="AccessCardsSearch.previousResult();">‹ <i18n:text key="search.common.previous" /></a>
				<span class="search_count"></span>
				<a href="javascript:void(0);" class="button paging_button paging_button_next" onclick="AccessCardsSearch.nextResult();"><i18n:text key="search.common.next" /> ›</a>
			</div>
			<div class="clear"></div>
		</div>
		
		<div class="search_box">
			<div class="simple_search submit_on_enter">
				<div class="wide_query">
					<input type="text" name="query" class="big_input" placeholder="<i18n:text key="administration.accesscards.simple_term_title" />" />
				</div>
				<div class="buttons">
					<a class="main_button arrow_right" onclick="AccessCardsSearch.search('simple');"><i18n:text key="search.common.button.search" /></a>
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
						<div class="result {#cycle values=['odd', 'even']} {AccessControl.getOverlayClass($T.record.accessCard)}" rel="{$T.record.accessCard.id}">
							<div class="record">
								{#if $T.record.accessCard.code}<label><i18n:text key="administration.accesscards.field.code" /></label>: <strong>{$T.record.accessCard.code}</strong><br/>{#/if}
								{#if $T.record.accessCard.status}<label><i18n:text key="administration.accesscards.field.status" /></label>: {_('administration.accesscards.status.' + $T.record.accessCard.status)}<br/>{#/if}
								{#if $T.record.user}
									<div style="margin-top:4px; font-weight:700; color:#2563eb;">👤 {$T.record.user.name} ({$T.record.user.enrollment})</div>
								{#/if}
							</div>
							{#if $T.record.accessCard.status == 'available' || $T.record.accessCard.status == 'in_use'}
								<div class="buttons">
									{#if $T.record.accessCard.status == 'available'}<a class="button center" onclick="AccessControl.bindCard('{$T.record.accessCard.id}');">🔗 <i18n:text key="circulation.accesscards.bind_card" /></a>{#/if}
									{#if $T.record.accessCard.status == 'in_use'}<a class="button center" onclick="AccessControl.unbindCard('{$T.record.accessCard.id}', '{$T.record.user.id}');">🔓 <i18n:text key="circulation.accesscards.unbind_card" /></a>{#/if}
								</div>
							{#/if}
							<div class="clear"></div>
						</div>
					{#/for}
				--></textarea>
			</div>
			<div class="paging_bar"></div>		
		</div>
	</div>
</layout:body>
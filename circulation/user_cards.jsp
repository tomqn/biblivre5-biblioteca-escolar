<%@page import="biblivre.circulation.user.UserFields"%>
<%@page import="biblivre.core.utils.Constants"%>
<%@page import="biblivre.administration.usertype.UserTypeBO"%>
<%@page import="biblivre.administration.usertype.UserTypeDTO"%>
<%@page import="java.util.List"%>
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
	<script type="text/javascript" src="static/scripts/biblivre.circulation.user_cards.js"></script>		
	<script type="text/javascript" src="static/scripts/<%= UserFields.getFields((String) request.getAttribute("schema")).getCacheFileName() %>"></script>
	<script type="text/javascript" src="static/scripts/zebra_datepicker.js"></script>
	<link rel="stylesheet" type="text/css" href="static/styles/zebra.bootstrap.css">

	<style type="text/css">
		body, #circulation_user { font-family: 'Plus Jakarta Sans', system-ui, sans-serif !important; color: #0f172a; }
		#circulation_user { max-width: 960px !important; margin: 0 auto !important; padding: 0 8px !important; }
		.ncspacer { display: none !important; height: 0 !important; margin: 0 !important; }
		.page_help { background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 6px !important; color: #64748b !important; font-size: 11px !important; padding: 5px 10px !important; margin-bottom: 8px !important; }
		.page_title { background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%) !important; border-radius: 8px !important; padding: 8px 14px !important; margin-bottom: 4px !important; display: flex !important; align-items: center !important; gap: 8px !important; }
		.page_title .image { width: 24px !important; height: 24px !important; background: rgba(255, 255, 255, 0.12) !important; border-radius: 5px !important; display: flex !important; align-items: center !important; justify-content: center !important; float: none !important; }
		.page_title .image img { width: 13px !important; height: 13px !important; filter: brightness(0) invert(1) !important; }
		.page_title .text { font-size: 13px !important; font-weight: 800 !important; color: #ffffff !important; float: none !important; margin: 0 !important; }
		.page_title .subtext { font-size: 10px !important; color: #cbd5e1 !important; margin-top: 2px !important; }
		.page_title .subtext a { color: #93c5fd !important; font-weight: 700 !important; }
		.search_box { background: #ffffff !important; border: 1px solid #e2e8f0 !important; border-radius: 8px !important; padding: 8px 12px !important; margin-top: 4px !important; margin-bottom: 6px !important; }
		.simple_search { display: flex !important; align-items: center !important; flex-wrap: wrap !important; gap: 8px !important; }
		.simple_search .query { flex: 1 !important; min-width: 180px !important; float: none !important; }
		.simple_search .buttons { display: flex !important; align-items: center !important; gap: 6px !important; margin: 0 !important; padding: 0 !important; border: none !important; background: transparent !important; box-shadow: none !important; }
		input[type="text"].big_input { height: 30px !important; border-radius: 5px !important; border: 1px solid #cbd5e1 !important; padding: 0 10px !important; font-size: 12px !important; color: #0f172a !important; outline: none !important; width: 100% !important; }
		select.combo { height: 30px !important; border-radius: 5px !important; border: 1px solid #cbd5e1 !important; padding: 0 6px !important; font-size: 11px !important; background: #ffffff !important; outline: none !important; }
		.main_button { background: #0f172a !important; color: #ffffff !important; border: none !important; border-radius: 5px !important; height: 30px !important; padding: 0 12px !important; font-size: 11px !important; font-weight: 700 !important; display: inline-flex !important; align-items: center !important; cursor: pointer !important; }
		.main_button:hover { background: #1e293b !important; }
		.search_results .result { background: #ffffff !important; border: 1px solid #e2e8f0 !important; border-radius: 6px !important; padding: 6px 12px !important; margin-bottom: 5px !important; display: flex !important; align-items: center !important; justify-content: space-between !important; gap: 10px !important; }
		.search_results .result .record { flex: 1 !important; font-size: 11px !important; line-height: 1.3 !important; }
		.search_results .result .record label { font-weight: 700 !important; color: #0f172a !important; display: inline-block !important; min-width: 85px !important; }
		.search_results .result .buttons { background: transparent !important; border: none !important; padding: 0 !important; margin: 0 !important; box-shadow: none !important; display: flex !important; align-items: center !important; }
		a[rel="select_item"] { background: #2563eb !important; color: #ffffff !important; border-radius: 5px !important; height: 26px !important; padding: 0 10px !important; font-size: 11px !important; font-weight: 700 !important; border: none !important; display: inline-flex !important; align-items: center !important; }
		.selected_results_area fieldset.block { background: #f8fafc !important; border: 1px solid #cbd5e1 !important; border-radius: 8px !important; padding: 10px 14px !important; margin-bottom: 8px !important; }
		.selected_results_area legend { font-size: 12px !important; font-weight: 800 !important; color: #0f172a !important; }
		.select_bar a.button { background: #0f172a !important; color: #fff !important; border-radius: 5px !important; padding: 4px 10px !important; font-size: 11px !important; font-weight: 700 !important; border: none !important; }
	</style>

	<script type="text/javascript">
		var CirculationSearch = CreateSearch(CirculationSearchClass, {
			type: 'circulation.user',
			root: '#circulation_user',
			autoSelect: false,
			enableTabs: false,
			enableHistory: false,
			advancedSearchAsDefault: true,
			userCardSearch: true
		});

		$(document).ready(function() {
			var global = Globalize.culture().calendars.standard;
			$('input.datepicker').Zebra_DatePicker({
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
	<link rel="stylesheet" type="text/css" href="static/styles/biblivre.modern.css" />
</layout:head>

<%
	List<UserTypeDTO> userTypes = UserTypeBO.getInstance((String) request.getAttribute("schema")).list();
%>
<c:set var="user_field_prefix" value="<%= Constants.TRANSLATION_USER_FIELD %>" scope="page" />

<layout:body>
	<div id="circulation_user">
		<div class="page_help"><i18n:text key="circulation.user_cards.page_help" /></div>
		
		<div class="page_title">
			<div class="image"><img src="static/images/titles/search.png" /></div>
			<div class="simple_search text contains_subtext">
				<i18n:text key="search.common.simple_search" />
				<div class="subtext"><i18n:text key="search.common.switch_to" /> <a href="javascript:void(0);" onclick="CirculationSearch.switchToAdvancedSearch();"><i18n:text key="search.common.advanced_search" /></a></div>
			</div>
			<div class="advanced_search text contains_subtext">
				<i18n:text key="search.common.advanced_search" />
				<div class="subtext"><i18n:text key="search.common.switch_to" /> <a href="javascript:void(0);" onclick="CirculationSearch.switchToSimpleSearch();"><i18n:text key="search.common.simple_search" /></a></div>
			</div>
			<div class="clear"></div>
		</div>

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
						<input type="checkbox" name="users_without_user_card" id="users_without_user_card" value="true" checked="checked">
						<label class="search_label" for="users_without_user_card" style="cursor:pointer;"><i18n:text key="circulation.user.users_without_user_card" /></label>
					</div>
				</div>
				<div class="buttons" style="margin-top: 6px;">
					<a class="main_button arrow_right" onclick="CirculationSearch.search('advanced');"><i18n:text key="search.common.button.list_all" /></a>
				</div>
			</div>			
		</div>
		
		<div class="selected_results_area"></div>
		<textarea class="selected_results_area_template template"><!--
			{#if $T.length > 0}
				<fieldset class="block">
					<legend>{_p('circulation.user_cards.selected_records', $T.length)}</legend>
					<ul style="margin: 6px 0; padding-left: 18px; font-size: 11px;">
						{#foreach $T as record}
							<li rel="{$T.record.id}">{$T.record.enrollment} - {$T.record.name} <a class="xclose" style="color:#dc2626; cursor:pointer;" onclick="CirculationSearch.unselectRecord({$T.record.id});">&times;</a></li>
						{#/for}
					</ul>
					<div class="buttons">
						<a class="main_button center" onclick="CirculationLabels.printLabels();">🖨️ <i18n:text key="circulation.user_cards.button.print_user_cards" /></a>
					</div>
				</fieldset>
			{/#if}
		--></textarea>
	
		<div class="search_results_area">
			<div class="search_loading_indicator loading_indicator"></div>
			<div class="select_bar" style="margin-bottom: 6px;">
				<a class="button center" onclick="CirculationSearch.selectPageResults();">✅ <i18n:text key="circulation.user_cards.button.select_page" /></a> 
			</div>
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
								<a class="button center" rel="select_item" onclick="CirculationSearch.selectRecord('{$T.record.id}');">➕ <i18n:text key="circulation.user_cards.button.select_item" /></a>
							</div>
							<div class="clear"></div>
						</div>
					{#/for}
				--></textarea>
			</div>
			<div class="paging_bar"></div>		
		</div>
	</div>
</layout:body>
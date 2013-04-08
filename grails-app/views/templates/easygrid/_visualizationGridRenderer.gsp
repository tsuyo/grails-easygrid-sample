<script type="text/javascript">
    google.load('visualization', '1', {'packages':['table']});
    google.setOnLoadCallback(init${attrs.id});
    var baseDataSourceUrl = '${g.createLink(action: "${gridConfig.id}Rows")}';
    var dataSourceUrl = baseDataSourceUrl;

    var query, options, container;

    function init${attrs.id}() {
        query = new google.visualization.Query(dataSourceUrl);
        container = document.getElementById("${attrs.id}_div");

        <g:if test="${gridConfig.visualization.loadAllData}">
        // Send the query with a callback function.
        query.send(handleQueryResponse);
        //todo - add options

        </g:if>
        <g:else>
        options = {
                <g:each in="${gridConfig.visualization}" var="property" status="idx">
                <g:if test="${idx>0}">,</g:if> "${property.key}":${property.value}
        </g:each>
    };
    query.abort();
    var tableQueryWrapper = new TableQueryWrapper(query, container, options);
    tableQueryWrapper.sendAndDraw();

    </g:else>


    }

    function handleQueryResponse(response) {
//        console.log(response);
        if (response.isError()) {
            alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
            return;
        }

        var data = response.getDataTable();
        var visualization = new google.visualization.Table(container);
        visualization.draw(data, null);
    }

    /*
     function setOption(prop, value) {
     options[prop] = value;
     sendAndDraw();
     }
     */


    function rewriteDatasource${attrs.id}(form) {
        var ser = jQuery(form).serialize();
        console.log(ser);
        dataSourceUrl = baseDataSourceUrl + "?" + ser;
        init${attrs.id}();
        return false;
    }

</script>


%{--create a very basic search form--}%
<div id="${attrs.id}_FilterDiv">
    <form name="${attrs.id}_FilterForm" onsubmit="return rewriteDatasource${attrs.id}(this)" action="${gridConfig.id}Rows">
        <fieldset class="form">
            <g:hiddenField name="_filter" value="true"/>
            <g:findAll in="${gridConfig.columns}"   expr="${it.enableFilter}">
                <div class="fieldcontain  ">
                    <label for="${it.name}">
                        <g:message code="${it.label}" default="${it.label}"/>
                    </label>
                    <g:field name="${it.name}" type="${it.visualization.searchType}"/>
                </div>
            </g:findAll>
            <g:submitButton name="Filter"/>
        </fieldset>
    </form>

</div>

<div id="${attrs.id}_div"></div>

%{--
<form action="">
    Number of rows to show:
    <select onChange="setOption('pageSize', parseInt(this.value, 10))">
        <option selected=selected value="5">5</option>
        <option value="10">10</option>
        <option value="20">20</option>
        <option value="-1">-1</option>
    </select>
</form>--}%

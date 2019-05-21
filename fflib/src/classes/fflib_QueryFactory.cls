/**
 * Created by tahsin on 2019-05-16.
 */

public with sharing class GEN_QueryFactory extends fflib_QueryFactory{

    public static final String defaultOperator = 'AND';
    public static final String EXPOP_LIKE = 'LIKE';
    public static final String EXPOP_EQ = '=';
    public static final String EXPOP_NEQ = '!=';
    public static final String EXPOP_IN = 'IN';
    public static final String EXPOP_LEQ = '<=';
    public static final String EXPOP_GEQ = '>=';
    public static final String EXPOP_LESS = '<';
    public static final String EXPOP_GREATER = '>';
    public static final String LEFT_BRACKET = '(';
    public static final String RIGHT_BRACKET = ')';

    public static final Set<String> VALID_EXPOP = new Set<String>{EXPOP_LIKE,EXPOP_EQ,EXPOP_NEQ, EXPOP_IN, EXPOP_GEQ, EXPOP_LEQ, EXPOP_LESS, EXPOP_GREATER};

    public List<String> QueryFilter {get;set;}
    public String Operator {get;set;}


    /**
	 * Construct a new GEM_QueryFactory instance with no options other than the FROM caluse.
	 * You *must* call selectField(s) before {@link #toSOQL} will return a valid, runnable query.
	 * @param table	the SObject to be used in the FROM clause of the resultant query. This sets the value of {@link #table}.
	**/
    public GEN_QueryFactory(Schema.SObjectType table){
        super(table);
        Operator = defaultOperator;

    }

    public void addFilter(String field, Object filerCriteria){

        if(field !=null){
            if(filerCriteria instanceof List<Object>){
                addINFilter(field,(List<Object>)filerCriteria);
            }else{
                queryFilter.add(getParamValue(field,filerCriteria));
            }

        }
        setFilterString();
    }


    public void clearFilter(){
        queryFilter.clear();
    }


    public void addFilters(Map<String,Object> filter){
        initFilter(filter);
        setFilterString();
    }

    public void addLIKEFilter(String field, String filerCriteria){
        if(field !=null && filerCriteria !=null){

            queryFilter.add(getLikeParamValue(field,filerCriteria));
        }
        setFilterString();
    }

    public void addINFilter(String field, List<Object> filerCriteria){
        if(field !=null && filerCriteria !=null && !filerCriteria.isEmpty()){
            queryFilter.add(getParamValueIn(field,filerCriteria));
        }
        setFilterString();
    }

    private static String getParamValue(String fieldName, Object value){
        if(value instanceof String){
            return fieldName + EXPOP_EQ +'\''+ String.escapeSingleQuotes((String)value) + '\'';
        }else{
            return fieldName + EXPOP_EQ +''+ value;
        }
    }

    private static String getLikeParamValue(String fieldName, String value){
        if(fieldName !=null && value !=null && value !=''){
            return fieldName + ' '+EXPOP_LIKE+' \'%'+ String.escapeSingleQuotes(value) + '%\'';
        }else{
            return '';
        }
    }

    private static String getParamValueIn(String fieldName, List<Object>values){
        if(values!=null && !values.isEmpty()){
            List<String> inValue = new List<String>();
            if(values instanceof List<String> ){
                for(Object val :values){
                    if(val!=null && val!='')
                        inValue.add('\''+String.escapeSingleQuotes(String.valueOf(val))+'\'');
                }
            }else{
                for(Object val :values){
                    inValue.add(String.valueOf(val));
                }
            }
            return fieldName + ' '+EXPOP_IN+' '+LEFT_BRACKET + String.join(inValue,',') + RIGHT_BRACKET;
        }else{
            return '';
        }
    }

    private void initFilter(Map<String,Object> filter){
        if(filter !=null){
            for(String field : filter.keySet()) {
                if(field != null){
                    object value  = filter.get(field);
                    if( value instanceof List<Object> ){
                        addINFilter(field,(List<Object>)filter.get(field));
                    }else{
                        addFilter(field,filter.get(field));
                    }
                }

            }
        }
    }


    public void setFilterString(){

        String filterString;
        if(!queryFilter.isEmpty()){
            filterString = String.join(queryFilter, ' ' + Operator + ' ');
        }

        this.conditionExpression =filterString;

    }

}

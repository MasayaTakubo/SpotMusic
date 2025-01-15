package context;


import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

public class WebResponseContext implements ResponseContext {
    private Map<String, Object> resultMap = new HashMap<>();
    private String target;
    private HttpServletResponse _response;

    public WebResponseContext() {}

    @Override
    public void setTarget(String transferInfo) {
        target = "/WEB-INF/jsp/" + transferInfo + ".jsp";
    }

    @Override
    public String getTarget() {
        return target;
    }

    // 複数の結果を格納するためのメソッド
    //仮実装
    public void setResult(String key, Object value) {
        resultMap.put(key, value);
    }

    // ResponseContextインターフェースのsetResult(Object)メソッドを実装
    @Override
    public void setResult(Object bean) {
        // もし単一の結果を格納する場合、keyをデフォルトにして格納
        resultMap.put("defaultResult", bean);
    }

    // ResponseContextインターフェースのgetResult()メソッドを実装
    @Override
    public Object getResult() {
        // 必要に応じて、デフォルトの結果や、特定のキーに基づく結果を返す
    	//使用時要修正
        return resultMap.get("defaultResult");  // デフォルトの結果を返す
    }

    // resultMapから取得するメソッド
    public Object getResult(String key) {
        return resultMap.get(key);  // 指定されたキーで結果を取得
    }

    @Override
    public void setResponse(Object obj) {
    	 _response = (HttpServletResponse) obj;
    	    // JSON形式で返すためのContent-Typeを設定
    	    _response.setContentType("application/json");
    	    _response.setCharacterEncoding("UTF-8");
    }

    @Override
    public Object getResponse() {
        return _response;
    }

    // resultMapを取得するためのアクセサ（オプション）
    public Map<String, Object> getResultMap() {
        return resultMap;
    }
    
}




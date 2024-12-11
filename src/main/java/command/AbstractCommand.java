package command;
import context.RequestContext;
import context.ResponseContext;

public abstract class AbstractCommand {
	
    private RequestContext reqContext;

    public void init(RequestContext reqc) {
        reqContext=reqc;
    }

    public RequestContext getRequsetContext() {
        return reqContext;
    }
    
    public abstract ResponseContext execute(ResponseContext resc);
}

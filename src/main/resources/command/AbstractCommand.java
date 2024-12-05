package command;

public abstract class AbstractCommand {
	
    private RequestContext reqContext;

    public void init(RequestContext reqc) {
        reqContext=reqc;
    }

    public RequestContext getRequsetContext() {
        return reqContext;
    }
}

package command;

import context.ResponseContext;


public class ChatCommand extends AbstractCommand {
    
    @Override
    public ResponseContext execute(ResponseContext resc) {
        resc.setTarget("chat"); 
        return resc;
    }
}

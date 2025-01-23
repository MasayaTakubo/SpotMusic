package command;

import bean.blockBean;
import context.RequestContext;
import context.ResponseContext;
import dao.BlockedUserDAO;

public class AddBlockUserCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String userId = reqc.getParameter("userId")[0];
        String relationId = reqc.getParameter("relationId")[0];
        
        blockBean blockBean = new blockBean();
        blockBean.setUserId(userId);
        blockBean.setRelationId(relationId);
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        blockBean.setBlockerId(userId);
        blockBean.setBlockedId(blockDAO.getBlockedId(relationId));
        blockDAO.addBlock(blockBean);
        //blocklist.jspの表示のためのコード、ひとまずいらない
        //List<blockBean> blocks = blockDAO.getBlockList(userId);
        //resc.setResult(blocks);
        //resc.setTarget("blockList");
        resc.setTarget("login");
        return resc;
    }
}

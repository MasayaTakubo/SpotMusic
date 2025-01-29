package command;

import java.util.List;

import bean.blockBean;
import context.RequestContext;
import context.ResponseContext;
import dao.BlockedUserDAO;

public class AddBlockFriendCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String userId = reqc.getParameter("userId")[0];
        String relationId = reqc.getParameter("relationId")[0];
        
        blockBean blockBean = new blockBean();
        blockBean.setUserId(userId);
        blockBean.setRelationId(relationId);
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        String blockedId = blockDAO.getBlockedId(blockBean);
        blockBean.setBlockerId(userId);
        blockBean.setBlockedId(blockedId);
        blockDAO.addBlock(blockBean);
        List<blockBean> blocks = blockDAO.getBlockList(userId);
        resc.setResult(blocks);
        resc.setTarget("blockList");
        return resc;
    }
}

package command;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import bean.PlayListBean;
import bean.blockBean;
import bean.relationBean;
import bean.usersBean;
import context.RequestContext;
import context.ResponseContext;
import dao.BlockedUserDAO;
import dao.PlayListDAO;
import dao.RelationDAO;
import dao.UsersDAO;

public class ListRelationCommandMobile extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String userId = reqc.getParameter("userId")[0];

        Map<String, List<?>> data = getShowData(userId);
        resc.setResult(data);
        resc.setTarget("friendListMobile");
        return resc;
    }
    
    private Map<String, List<?>> getShowData(String userId){
    	//jspの表示に使うものは基本relation,users,blockedUsers表しかないからまとめる
        RelationDAO relationDAO = new RelationDAO();
        List<relationBean> relations = relationDAO.getRelation(userId);
        UsersDAO usersDAO = new UsersDAO();
        List<usersBean> users = usersDAO.getUsersData();
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        List<blockBean> blockusers = blockDAO.getBlockList(userId);
        PlayListDAO playlistDAO = new PlayListDAO();
        List<String> friends = playlistDAO.getFriends(userId);
        List<List> friendsList = new ArrayList<>();
        for (String friend : friends) {
        	List<PlayListBean> friendsPlayList = playlistDAO.getFriendPlayList(friend);
        	friendsList.add(friendsPlayList);
        }
        Map<String, List<?>> data = new HashMap<>();
        data.put("users",users);
        data.put("relations",relations);
        data.put("blockusers", blockusers);
        data.put("friendsList", friendsList);
    	return data;
    }
}

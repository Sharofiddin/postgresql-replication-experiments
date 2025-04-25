package uz.learn.task;
import io.quarkus.hibernate.reactive.panache.common.WithTransaction;
import io.quarkus.reactive.datasource.ReactiveDataSource;
import io.smallrye.mutiny.Uni;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Response;
import io.vertx.mutiny.sqlclient.Pool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.RowIterator;
import io.vertx.mutiny.sqlclient.Tuple;

import java.util.ArrayList;
import java.util.List;

@Path("tasks")
@Produces("application/json")
@Consumes("application/json")
public class TaskResource {

 @Inject
 private Pool primaryClient; 

 @Inject
 @ReactiveDataSource("replica-sync")
 private Pool syncReplicaClient; 
 
 @Inject
 @ReactiveDataSource("replica-async")
 private  Pool asyncReplicaClient; 

 @GET
 public Uni<List<Task>> tasks(){
    return getTasks(syncReplicaClient);
	}


private Uni<List<Task>> getTasks(Pool replicaClient) {
	return replicaClient.query("""
    		SELECT id, name, scheduledat, status FROM task
    		""").execute().map(rows->{
     List<Task> tasks = new ArrayList<>();
      RowIterator<Row> iterator = rows.iterator();
      while(iterator.hasNext()) {
    	  Row row = iterator.next();
    	  Task task = new Task();
    	  task.id = row.getLong("id");
    	  task.name = row.getString("name");
    	  task.scheduledAt = row.getLocalDateTime("scheduledat");
    	  task.status = row.getString("status");
    	  tasks.add(task);
      }
      return tasks;
    });
}


 @GET
 @Path("/async")
 public Uni<List<Task>> tasksAsync(){
	 return getTasks(asyncReplicaClient);
	}

  @POST
  @WithTransaction
    public Uni<Response> create(Task task) {
	return primaryClient.preparedQuery("""
			INSERT INTO public.task(
			   id,
			   name, 
			   scheduledat, 
			   status) 
			VALUES (
			   (select nextval('task_seq')),
			    $1, 
			   $2, 
			   $3)
					""")
	.execute(Tuple.of(task.name, task.scheduledAt, "PENDING"))
//	.execute(Tuple.of(task.name, task.scheduledAt, "PENDING"))
	.map(item->Response.ok().build());
 }
}

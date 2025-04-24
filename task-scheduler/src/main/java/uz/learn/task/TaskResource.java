package uz.learn.task;
import io.quarkus.hibernate.reactive.panache.common.WithTransaction;
import io.quarkus.panache.common.Sort;
import io.smallrye.mutiny.Uni;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Response;

import java.util.List;

@Path("tasks")
@Produces("application/json")
@Consumes("application/json")
public class TaskResource {
  
 @GET
 public Uni<List<Task>> tasks(){
    return Task.listAll(Sort.by("scheduledAt"));
	}

  @POST
  @WithTransaction
  public Uni<Response> create(Task task) {
    task.status = "PENDING";
    return task.persist().map(item->Response.ok(item).build());
 }
}

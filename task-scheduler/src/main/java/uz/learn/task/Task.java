package uz.learn.task;
import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Entity;


@Entity
class Task extends PanacheEntity {
  public String name;
  public LocalDateTime scheduledAt;
  public String status; //PENDING, COMPLETED
}

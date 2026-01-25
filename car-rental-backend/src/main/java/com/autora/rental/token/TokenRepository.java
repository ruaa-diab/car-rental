package com.autora.rental.token;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TokenRepository extends JpaRepository<Token, Long> {

    @Query("""
        SELECT t FROM Token t 
        INNER JOIN t.user u 
        WHERE u.id = :userId 
        AND (t.expired = false OR t.revoked = false)
    """)
    List<Token> findAllValidTokenByUser(Long userId);

    Optional<Token> findByToken(String token);
}

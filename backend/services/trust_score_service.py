def calcular_trust_score(reviews, publicaciones):

    if not reviews:
        rating_promedio = 0
        total_reviews = 0
    else:
        total_reviews = len(reviews)
        rating_promedio = sum(r["estrellas"] for r in reviews) / total_reviews

    score_rating = rating_promedio * 20
    score_reviews = min(total_reviews * 2, 20)
    score_publicaciones = min(len(publicaciones) * 2, 20)

    score_total = score_rating + score_reviews + score_publicaciones

    score_normalizado = min(int(score_total / 1.4), 100)

    return score_normalizado